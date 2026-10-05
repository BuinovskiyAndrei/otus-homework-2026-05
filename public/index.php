<?php

declare(strict_types=1);

include __DIR__ . '/../vendor/autoload.php';

use App\Modules\Email\Helpers\EmailVerifier;

$verifier = new EmailVerifier();
$emails = ["example@gmail.com", "invalid-email", "test@example.ru"];
$results = $verifier->validateEmails($emails);