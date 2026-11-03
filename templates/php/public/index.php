<?php

header('Content-Type: application/json');

echo json_encode([
    'status' => 'success',
    'message' => 'PHP project initialized with Nix devShell!',
    'php_version' => PHP_VERSION,
    'timestamp' => date('c'),
], JSON_PRETTY_PRINT) . PHP_EOL;
