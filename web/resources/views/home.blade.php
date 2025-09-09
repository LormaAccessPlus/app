<?php /** now uses the app component */ ?>
<x-app title="Dashboard">
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
</x-app>
