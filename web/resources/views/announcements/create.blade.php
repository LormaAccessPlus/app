<?php
?>
<!doctype html>
<html>
<head><title>Create Announcement</title></head>
<body>
@if(session('success')) <div style="color:green">{{ session('success') }}</div> @endif

<form method="POST" action="{{ route('announcements.store') }}">
    @csrf

    <div>
        <label>Title</label><br>
        <input name="title" value="{{ old('title') }}" required />
    </div>

    <div>
        <label>Body</label><br>
        <textarea name="body" rows="6" required>{{ old('body') }}</textarea>
    </div>

    <div>
        <label>Publish At (optional)</label><br>
        <input type="datetime-local" name="published_at" value="{{ old('published_at') }}" />
    </div>

    <div>
        <label>Pinned</label>
        <input type="checkbox" name="pinned" value="1" {{ old('pinned') ? 'checked' : '' }} />
    </div>

    <button type="submit">Create</button>
</form>
</body>
</html>