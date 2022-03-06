<?php

namespace App;

class Welcome
{
    private string $name;
    
    public function __construct(string $name)
    {
        $this->name = $name;
    }
    
    public function __toString()
    {
        return 'Hello ' . $this->name . '!';
    }
}