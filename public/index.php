<?php

declare(strict_types=1);

require __DIR__ . '/../vendor/autoload.php';

use App\Modules\Email\Helpers\EmailVerifier;

$verifier = new EmailVerifier();
$emails = ["example@gmail.com", "asd@asdd@gmail.com", "invalid-email", "test@example.ru"];
$results = $verifier->validateEmails($emails);

echo '<pre>';print_r($results);echo '</pre>';