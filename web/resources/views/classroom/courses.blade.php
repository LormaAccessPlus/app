<?php
?>
<!doctype html>
<html>
<head>
    <meta charset="utf-8">
    <title>Classroom Subjects</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
</head>
<body class="p-4">
<div class="container">
    <h1 class="mb-4">Subjects</h1>

    <div class="mb-3">
        <a class="btn btn-primary" href="{{ route('auth.google.redirect') }}">Connect Google Classroom</a>
    </div>

    @if(!empty($error))
        <div class="alert alert-danger">{{ $error }}</div>
    @endif

    @if(empty($subjectsByYear) || collect($subjectsByYear)->map(fn($s) => array_merge($s['First'],$s['Second'],$s['Unknown']))->flatten(1)->isEmpty())
        <div class="alert alert-info">No subjects found.</div>
    @else
        @foreach($subjectsByYear as $year => $sems)
            <h2 class="mt-4">{{ $year }}</h2>

            <div class="row">
                <div class="col-md-4">
                    <h4>First Semester</h4>
                    @if(empty($sems['First']))
                        <div class="text-muted">No subjects.</div>
                    @else
                        <table class="table table-sm">
                            <thead><tr><th>Name</th><th>Section</th><th>Room</th><th>Link</th></tr></thead>
                            <tbody>
                            @foreach($sems['First'] as $s)
                                <tr>
                                    <td>{{ $s['name'] }}</td>
                                    <td>{{ $s['section'] }}</td>
                                    <td>{{ $s['room'] }}</td>
                                    <td>@if($s['link']) <a href="{{ $s['link'] }}" target="_blank">Open</a> @endif</td>
                                </tr>
                            @endforeach
                            </tbody>
                        </table>
                    @endif
                </div>

                <div class="col-md-4">
                    <h4>Summer</h4>
                    @if(empty($sems['Summer']))
                        <div class="text-muted">No subjects.</div>
                    @else
                        <table class="table table-sm">
                            <thead><tr><th>Name</th><th>Section</th><th>Room</th><th>Link</th></tr></thead>
                            <tbody>
                            @foreach($sems['Summer'] as $s)
                                <tr>
                                    <td>{{ $s['name'] }}</td>
                                    <td>{{ $s['section'] }}</td>
                                    <td>{{ $s['room'] }}</td>
                                    <td>@if($s['link']) <a href="{{ $s['link'] }}" target="_blank">Open</a> @endif</td>
                                </tr>
                            @endforeach
                            </tbody>
                        </table>
                    @endif
                </div>

                <div class="col-md-4">
                    <h4>Second Semester</h4>
                    @if(empty($sems['Second']))
                        <div class="text-muted">No subjects.</div>
                    @else
                        <table class="table table-sm">
                            <thead><tr><th>Name</th><th>Section</th><th>Room</th><th>Link</th></tr></thead>
                            <tbody>
                            @foreach($sems['Second'] as $s)
                                <tr>
                                    <td>{{ $s['name'] }}</td>
                                    <td>{{ $s['section'] }}</td>
                                    <td>{{ $s['room'] }}</td>
                                    <td>@if($s['link']) <a href="{{ $s['link'] }}" target="_blank">Open</a> @endif</td>
                                </tr>
                            @endforeach
                            </tbody>
                        </table>
                    @endif
                </div>
            </div>

            @if(!empty($sems['Unknown']))
                <h5 class="mt-3">Uncategorized</h5>
                <table class="table table-sm">
                    <thead><tr><th>Name</th><th>Section</th><th>Room</th><th>Link</th></tr></thead>
                    <tbody>
                    @foreach($sems['Unknown'] as $s)
                        <tr>
                            <td>{{ $s['name'] }}</td>
                            <td>{{ $s['section'] }}</td>
                            <td>{{ $s['room'] }}</td>
                            <td>@if($s['link']) <a href="{{ $s['link'] }}" target="_blank">Open</a> @endif</td>
                        </tr>
                    @endforeach
                    </tbody>
                </table>
            @endif

        @endforeach
    @endif

</div>
</body>
</html>