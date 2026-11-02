<?php

declare(strict_types=1);

namespace App;

use Elastic\Elasticsearch\Client;
use Elastic\Elasticsearch\ClientBuilder;
use Elastic\Elasticsearch\Response\Elasticsearch;

final class ElasticsearchProductSearchRepository implements ProductSearchRepositoryInterface
{
    private const INDEX = 'products';

    private Client $client;

    public function __construct(?string $host = null)
    {
        $this->client = ClientBuilder::create()
            ->setHosts([$host ?? getenv('ELASTICSEARCH_HOST') ?: 'http://localhost:9200'])
            ->build();
    }

    public function recreateIndex(): void
    {
        if ($this->client->indices()->exists(['index' => self::INDEX])->asBool()) {
            $this->client->indices()->delete(['index' => self::INDEX]);
        }

        $this->client->indices()->create([
            'index' => self::INDEX,
            'body' => [
                'settings' => [
                    'analysis' => [
                        'analyzer' => [
                            'ru' => [
                                'type' => 'russian',
                            ],
                        ],
                    ],
                ],
                'mappings' => [
                    'properties' => [
                        'title' => ['type' => 'text', 'analyzer' => 'ru'],
                        'category' => [
                            'type' => 'text',
                            'analyzer' => 'ru',
                            'fields' => [
                                'keyword' => ['type' => 'keyword'],
                            ],
                        ],
                        'price' => ['type' => 'integer'],
                        'stock' => ['type' => 'integer'],
                    ],
                ],
            ],
        ]);
    }

    public function bulkIndex(array $products): void
    {
        $body = [];
        foreach ($products as $product) {
            $body[] = ['index' => ['_index' => self::INDEX, '_id' => (string) $product['id']]];
            $body[] = [
                'title' => $product['title'],
                'category' => $product['category'],
                'price' => $product['price'],
                'stock' => $product['stock'],
            ];
        }

        if ($body === []) {
            return;
        }

        $response = $this->client->bulk(['body' => $body]);
        $this->assertNoBulkErrors($response);
        $this->client->indices()->refresh(['index' => self::INDEX]);
    }

    public function search(SearchCriteria $criteria): array
    {
        $filters = [];
        if ($criteria->maxPrice !== null) {
            $filters[] = ['range' => ['price' => ['lt' => $criteria->maxPrice]]];
        }

        if ($criteria->inStockOnly) {
            $filters[] = ['range' => ['stock' => ['gt' => 0]]];
        }

        if ($criteria->category !== null) {
            $filters[] = ['term' => ['category.keyword' => $criteria->category]];
        }

        $body = [
            'query' => [
                'bool' => [
                    'must' => [
                        [
                            'multi_match' => [
                                'query' => $criteria->query,
                                'fields' => ['title^2'],
                                'fuzziness' => 'AUTO',
                            ],
                        ],
                    ],
                ],
            ],
            'sort' => [['_score' => 'desc']],
        ];

        if ($filters !== []) {
            $body['query']['bool']['filter'] = $filters;
        }

        $response = $this->client->search([
            'index' => self::INDEX,
            'body' => $body,
        ]);

        $hits = [];
        foreach ($response['hits']['hits'] as $hit) {
            $source = $hit['_source'];
            $hits[] = new ProductHit(
                id: (int) $hit['_id'],
                title: (string) $source['title'],
                category: (string) $source['category'],
                price: (int) $source['price'],
                stock: (int) $source['stock'],
                score: (float) $hit['_score'],
            );
        }

        return $hits;
    }

    private function assertNoBulkErrors(Elasticsearch $response): void
    {
        if ($response['errors'] ?? false) {
            throw new \RuntimeException('Bulk index failed');
        }
    }
}
