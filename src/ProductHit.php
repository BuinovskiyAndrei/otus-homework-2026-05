<?php

declare(strict_types=1);

namespace App;

final readonly class ProductHit
{
    public function __construct(
        public int $id,
        public string $title,
        public string $category,
        public int $price,
        public int $stock,
        public float $score,
    ) {
    }
}
