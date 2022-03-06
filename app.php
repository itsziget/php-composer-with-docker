<?php

use App\Welcome;

require_once __DIR__ . '/vendor/autoload.php';

$welcome = new Welcome("John");

echo $welcome . "\n";
