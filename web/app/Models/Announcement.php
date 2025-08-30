<?php

namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Announcement extends Model
{
    protected $fillable = ['title','body','created_by','published_at','pinned'];
    protected $dates = ['published_at'];
}