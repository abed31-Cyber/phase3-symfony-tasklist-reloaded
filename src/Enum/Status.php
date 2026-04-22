<?php

namespace App\Enum;

enum Status: string
{
    case Pending = 'pending';
    case Completed = 'completed';
    case Archived = 'archived';
}
