@php

@endphp
<!doctype html>
<html>
<head>
    <meta charset="utf-8">
    <title>{{ $title ?? 'App' }}</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- quick layout CSS (Bootstrap used for speed) -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        :root{
            --primary: #08695A;
            --primary-contrast: #e9f6f2;
            --primary-strong: #08695A;
        }

        body { background:#f6f8fa; }
        .app { display:flex; min-height:100vh; }

        /* { changed code } reduce bottom spacing under logo */
        .sidebar { width:260px; background:#fff; border-right:1px solid #e6eef0; padding:0; }
        .brand { display:flex; align-items:center; gap:10px; margin-bottom:1px; padding:1px 8px; }
        .brand img { width:100%; max-width:100px; height:auto; display:block; margin-bottom:0; }

        /* remove extra gap from hr */
        hr { margin: 0; border: 0; height: 1px; background: #e6eef0; }

        .user-card { display:flex; gap:12px; align-items:center; padding:12px;  color:#ffffff; border:1px solid rgba(0,0,0,0.03); margin-bottom:18px; }
        .user-card div { color: #fff; }

        .nav-link { color:#2b5b52; padding:10px 12px;  display:flex; align-items:center; gap:10px; }
        .nav-link.active, .nav-link:hover { background:var(--primary); color:#ffffff; text-decoration:none; }
        .main { flex:1; padding:28px; }
        .card-dashboard { border:1px solid #e6eef0; padding:18px; background:#fff; }
        .small-meta { font-size:12px; color:#6b6f72; }
        .kpi-number { font-size:20px; font-weight:700; color:var(--primary-strong); }
        .header-row { display:flex; justify-content:space-between; align-items:center; margin-bottom:18px; }
    </style>
</head>
<body>
<div class="app">
    <aside class="sidebar">
        <div class="brand">
            <img src="{{ asset('images/Lorma_Colleges_Logo.png') }}" alt="Lorma Colleges Logo" style="max-width:100px; height:auto;">
        </div>
        
        <div class="user-card">
            <div style="width:44px;height:44px;background:#e9f6f2;display:flex;align-items:center;justify-content:center;color:#08695a;font-weight:700">
                {{ strtoupper(substr(Auth::user()->name ?? '-',0,1)) }}
            </div>
            <div>
                <div style="font-weight:600; color: #08695A;">{{ Auth::user()->name ?? 'User' }}</div>
                <div style="font-size:12px;color:#7d8a89">Faculty / Computer Science</div>
            </div>
        </div>

        <nav class="nav flex-column">
            <a class="nav-link {{ request()->is('home') ? 'active' : '' }}" href="{{ url('/home') }}"><i class="bi bi-speedometer2"></i> Dashboard</a>
            <a class="nav-link {{ request()->is('classroom/*') ? 'active' : '' }}" href="{{ url('/classroom/courses') }}"><i class="bi bi-journal"></i> Classes</a>
            <a class="nav-link {{ request()->is('grade-sync') ? 'active' : '' }}" href="{{ url('/grade-sync') }}"><i class="bi bi-arrow-repeat"></i> Grade Sync</a>
            @if(Auth::check() && (Auth::user()->is_super_admin ?? false))
                <a class="nav-link {{ request()->is('admin') ? 'active' : '' }}" href="{{ route('admin.index') }}"><i class="bi bi-shield-lock"></i> Admin</a>
            @endif
            <a class="nav-link {{ request()->is('profile') ? 'active' : '' }}" href="{{ url('/profile') }}"><i class="bi bi-person"></i> Profile</a>
            <a class="nav-link mt-3 text-danger" href="{{ route('logout') }}">Logout</a>
        </nav>
    </aside>

    <main class="main">
        {{-- slot will contain page-specific content --}}
        @yield('content')
    </main>
</div>

<!-- Bootstrap icons and JS (optional) -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>