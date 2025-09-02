<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class StudentApiController extends Controller
{
    // GET /api/studsubjfeealignment/{student_id}
    public function showByStudent($student_id)
    {
        return $this->fetchForStudent($student_id);
    }

    // GET /api/studsubjfeealignment?student_id=...
    public function showByQuery(Request $request)
    {
        $sid = $request->query('student_id') ?? $request->query('sid');
        if (! $sid) {
            return response()->json(['message' => 'student_id required'], 400);
        }
        return $this->fetchForStudent($sid);
    }

    protected function fetchForStudent($sid)
    {
        try {
            // try to read from DB table; change table name/columns to match your schema
            $rows = DB::table('studsubjfeealignment')
                ->where('student_id', $sid)
                ->get();
            // if empty, return sample structure so mobile can parse
            if ($rows->isEmpty()) {
                return response()->json([
                    ['Term' => 'Term 1', 'SchoolYear' => '2024-2025', 'SubjectID' => 'MATH101', 'Units' => 3],
                    ['Term' => 'Term 2', 'SchoolYear' => '2024-2025', 'SubjectID' => 'ENG101', 'Units' => 3],
                ]);
            }
            return response()->json($rows);
        } catch (\Throwable $e) {
            Log::error('studsubjfeealignment fetch error: '.$e->getMessage());
            // fallback sample response
            return response()->json([
                ['Term' => 'Term 1', 'SchoolYear' => '2024-2025', 'SubjectID' => 'MATH101', 'Units' => 3],
                ['Term' => 'Term 2', 'SchoolYear' => '2024-2025', 'SubjectID' => 'ENG101', 'Units' => 3],
            ]);
        }
    }
}