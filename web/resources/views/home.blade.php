<?php
?>
<!DOCTYPE html>
<html>
<head>
    <title>Home</title>
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
<hr>
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
            <a class="nav-link active" href="{{ url('/home') }}"><i class="bi bi-speedometer2"></i> Dashboard</a>
            <a class="nav-link" href="{{ url('/classes') }}"><i class="bi bi-journal"></i> Classes</a>
            <a class="nav-link" href="{{ url('/grade-sync') }}"><i class="bi bi-arrow-repeat"></i> Grade Sync</a>
            <a class="nav-link" href="{{ url('/profile') }}"><i class="bi bi-person"></i> Profile</a>
            <a class="nav-link mt-3 text-danger" href="{{ route('logout') }}">Logout</a>
        </nav>
    </aside>

    <main class="main">
        <div class="header-row">
            <div>
                <h2 style="margin:0">Dashboard</h2>
                <small class="small-meta">Welcome Back!</small>
            </div>
            <div>
                <!-- top-right actions (notifications, etc) -->
            </div>
        </div>

        <div class="row g-3 mb-3">
            <div class="col-md-4">
                <div class="card-dashboard">
                    <div class="small-meta">Total Class<br><span class="kpi-number">{{ $totalClasses ?? 5 }}</span></div>
                    <div class="mt-2"><a href="{{ url('/classes') }}">View Classes</a></div>
                </div>
            </div>

            <div class="col-md-4">
                <div class="card-dashboard">
                    <div class="small-meta">Total Students<br><span class="kpi-number">{{ $totalStudents ?? 145 }}</span></div>
                    <div class="mt-2"><a href="{{ url('/students') }}">View student details</a></div>
                </div>
            </div>

            <div class="col-md-4">
                <div class="card-dashboard">
                    <div class="small-meta">Pending Grades<br><span class="kpi-number">{{ $pendingGrades ?? 5 }}</span></div>
                    <div class="mt-2"><a href="{{ url('/grade-sync') }}">View all classes</a></div>
                </div>
            </div>
        </div>

        <!-- place for additional dashboard widgets -->
        <section>
            <h5>Announcements</h5>
            <div class="row">
                <!-- if you have a partial for announcements, include it; fallback show link -->
                <div class="col-12">
                    <a href="{{ url('/announcements') }}" class="btn btn-outline-primary btn-sm mb-2">View all</a>
                    @if(isset($announcements) && count($announcements))
                        @foreach($announcements as $a)
                            <div class="card mb-2">
                                <div class="card-body">
                                    <h6 class="card-title mb-1">{{ $a->title }}</h6>
                                    <p class="card-text text-muted" style="margin:0">{{ Str::limit($a->body, 160) }}</p>
                                </div>
                            </div>
                        @endforeach
                    @else
                        <div class="alert alert-info">No announcements yet. <a href="{{ route('announcements.create') }}">Create one</a></div>
                    @endif
                </div>
            </div>
        </section>
    </main>
</div>

<!-- Bootstrap icons and JS (optional) -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
