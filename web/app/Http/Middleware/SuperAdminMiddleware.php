<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Support\Facades\Auth;

class SuperAdminMiddleware
{
    public function handle($request, Closure $next)
    {
        // Example: restrict by email
        if (Auth::check() && Auth::user()->email === 'leandroraphael.tenorio@lorma.edu') {
            return $next($request);
        }

        abort(403, 'Unauthorized');
    }
}
