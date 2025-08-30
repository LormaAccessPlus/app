<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Announcement;

class HomeController extends Controller
{
    public function index()
    {
        // load published announcements (most recent + pinned first)
        $announcements = Announcement::whereNotNull('published_at')
            ->orderBy('pinned', 'desc')
            ->orderBy('published_at', 'desc')
            ->get();

        // placeholders — replace with real queries if available
        $totalClasses = null;
        $totalStudents = null;
        $pendingGrades = null;

        return view('home', compact('announcements', 'totalClasses', 'totalStudents', 'pendingGrades'));
    }
}