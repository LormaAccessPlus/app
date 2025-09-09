<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class EnsureSuperAdmin
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next)
    {
        // Replace 'is_super_admin' with your actual super admin check
        if (!Auth::check() || !Auth::user()->is_super_admin) {
            abort(403, 'Unauthorized');
        }
        return $next($request);
    }
}