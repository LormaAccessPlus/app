<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Announcement;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;

class AnnouncementsController extends Controller
{
    // show create form (web)
    public function create()
    {
        return view('announcements.create');
    }

    // store (web)
    public function store(Request $request)
    {
        $data = $request->validate([
            'title' => 'required|string|max:255',
            'body' => 'required|string',
            'published_at' => 'nullable|date',
            'pinned' => 'sometimes|boolean',
        ]);

        $data['created_by'] = Auth::id();

        // if no published_at provided, publish immediately
        if (empty($data['published_at'])) {
            $data['published_at'] = now();
        }

        // normalize pinned checkbox
        $data['pinned'] = !empty($data['pinned']) ? true : false;

        Announcement::create($data);

        return redirect()->route('announcements.index')->with('success', 'Announcement created.');
    }

    // web: show list of announcements
    public function index()
    {
        $items = Announcement::orderBy('pinned','desc')
            ->orderBy('published_at','desc')
            ->get();
        return view('announcements.index', ['announcements' => $items]);
    }

    // API endpoint for mobile
    public function apiIndex(Request $request)
    {
        // show all announcements (remove whereNotNull if you want drafts too)
        $items = Announcement::orderBy('pinned','desc')
            ->orderBy('published_at','desc')
            ->get(['id','title','body','published_at','pinned','created_at']);

        return response()->json($items);
    }
}