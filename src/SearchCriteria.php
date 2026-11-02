<?php

declare(strict_types=1);

namespace App;

final readonly class SearchCriteria
{
    public function __construct(
        public string $query,
        public ?int $maxPrice = null,
        public bool $inStockOnly = false,
        public ?string $category = null,
    ) {
    }
}
