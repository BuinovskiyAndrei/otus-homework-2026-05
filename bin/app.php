#!/usr/bin/env php
<?php

declare(strict_types=1);

use App\ElasticsearchProductSearchRepository;
use App\ProductSearchRepositoryInterface;
use App\SearchCriteria;

require dirname(__DIR__) . '/vendor/autoload.php';

$command = $argv[1] ?? null;

if ($command === 'index') {
    $path = $argv[2] ?? dirname(__DIR__) . '/products.json';
    runIndex($path, new ElasticsearchProductSearchRepository());
    exit(0);
}

if ($command === 'search') {
    [$query, $maxPrice, $inStock, $category] = parseSearchArgs($argv);
    if ($query === null || $query === '') {
        fwrite(STDERR, "Usage: php bin/app.php search --q=QUERY [--max-price=N] [--in-stock] [--category=CATEGORY]\n");
        exit(1);
    }

    $criteria = new SearchCriteria($query, $maxPrice, $inStock, $category);
    $hits = (new ElasticsearchProductSearchRepository())->search($criteria);
    printTable($hits);
    exit(0);
}

fwrite(STDERR, "Usage:\n");
fwrite(STDERR, "  php bin/app.php index [path/to/products.json]\n");
fwrite(STDERR, "  php bin/app.php search --q=QUERY [--max-price=N] [--in-stock] [--category=CATEGORY]\n");
exit(1);

/**
 * @return array{0: ?string, 1: ?int, 2: bool, 3: ?string}
 */
function parseSearchArgs(array $argv): array
{
    $query = null;
    $maxPrice = null;
    $inStock = false;
    $category = null;

    for ($i = 2, $n = count($argv); $i < $n; $i++) {
        $arg = $argv[$i];

        if ($arg === '--in-stock') {
            $inStock = true;
            continue;
        }
        if (str_starts_with($arg, '--q=')) {
            $query = substr($arg, 4);
            continue;
        }
        if ($arg === '--q' && isset($argv[$i + 1])) {
            $query = $argv[++$i];
            continue;
        }
        if (str_starts_with($arg, '--max-price=')) {
            $maxPrice = (int)substr($arg, 12);
            continue;
        }
        if ($arg === '--max-price' && isset($argv[$i + 1])) {
            $maxPrice = (int)$argv[++$i];
            continue;
        }
        if (str_starts_with($arg, '--category=')) {
            $value = substr($arg, 11);
            $category = $value === '' ? null : $value;
            continue;
        }
        if ($arg === '--category' && isset($argv[$i + 1])) {
            $value = $argv[++$i];
            $category = $value === '' ? null : $value;
            continue;
        }
    }

    return [$query, $maxPrice, $inStock, $category];
}

function runIndex(string $path, ProductSearchRepositoryInterface $repository): void
{
    if (!is_readable($path)) {
        throw new RuntimeException("Cannot read file: {$path}");
    }

    $json = file_get_contents($path);
    $products = json_decode($json ?: '', true, 512, JSON_THROW_ON_ERROR);
    if (!is_array($products)) {
        throw new RuntimeException('Invalid JSON: expected array');
    }

    $repository->recreateIndex();
    $repository->bulkIndex($products);
    echo "Indexed " . count($products) . " products from {$path}\n";
}

/**
 * @param list<\App\ProductHit> $hits
 */
function printTable(array $hits): void
{
    if ($hits === []) {
        echo "No results\n";
        return;
    }

    $headers = ['score', 'id', 'title', 'category', 'price', 'stock'];
    $rows = [];
    foreach ($hits as $hit) {
        $rows[] = [
                sprintf('%.4f', $hit->score),
                (string)$hit->id,
                $hit->title,
                $hit->category,
                (string)$hit->price,
                (string)$hit->stock,
        ];
    }

    $widths = [];
    foreach ($headers as $i => $header) {
        $widths[$i] = mb_strlen($header);
    }
    foreach ($rows as $row) {
        foreach ($row as $i => $cell) {
            $widths[$i] = max($widths[$i], mb_strlen($cell));
        }
    }

    $pad = static function (string $cell, int $width): string {
        return $cell . str_repeat(' ', max(0, $width - mb_strlen($cell)));
    };

    $line = static function (array $cells) use ($widths, $pad): string {
        $parts = [];
        foreach ($cells as $i => $cell) {
            $parts[] = $pad($cell, $widths[$i]);
        }
        return '| ' . implode(' | ', $parts) . ' |';
    };

    $separator = '+-' . implode('-+-', array_map(static fn(int $w) => str_repeat('-', $w), $widths)) . '-+';

    echo $separator . "\n";
    echo $line($headers) . "\n";
    echo $separator . "\n";
    foreach ($rows as $row) {
        echo $line($row) . "\n";
    }
    echo $separator . "\n";
}
