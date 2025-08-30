<?php
?>
<!doctype html>
<html>
<head><title>Announcements</title></head>
<body>
    <h1>Announcements</h1>

    <p><a href="{{ route('announcements.create') }}">Create announcement</a></p>

    @foreach($announcements as $a)
        <div style="border:1px solid #ddd;padding:12px;margin:8px 0;">
            <h3>{{ $a->title }} @if($a->pinned) <small>(pinned)</small> @endif</h3>
            <div><small>Published: {{ $a->published_at ?? $a->created_at }}</small></div>
            <p>{{ $a->body }}</p>
        </div>
    @endforeach
</body>
</html>