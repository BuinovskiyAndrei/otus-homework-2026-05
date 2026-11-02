<?php

declare(strict_types=1);

namespace App;

interface ProductSearchRepositoryInterface
{
    public function recreateIndex(): void;

    /**
     * @param list<array{id: int, title: string, category: string, price: int, stock: int}> $products
     */
    public function bulkIndex(array $products): void;

    /**
     * @return list<ProductHit>
     */
    public function search(SearchCriteria $criteria): array;
}
