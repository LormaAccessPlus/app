<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class AbsencesController extends Controller
{
    /**
     * Return student absences as JSON
     * GET /api/absences/{studid}
     */
    public function forStudent(Request $request, $studid = null)
    {
        $id = $studid ?? $request->query('student_id');
        if (empty($id)) {
            return response()->json(['error' => 'student id required'], 400);
        }

        try {
            $rows = DB::select(
                'SELECT ID, StudID, SchedID, MultiID, AbsDate, RecordedBy, RecordedDate, Remarks, Hours FROM studentabsence WHERE StudID = ?',
                [$id]
            );

            Log::info('AbsencesController raw rows: ' . json_encode($rows));

            $rows = array_map(function ($r) {
                return (array) $r;
            }, $rows);

            return response()->json(array_values($rows));
        } catch (\Throwable $e) {
            Log::error('AbsencesController error: ' . $e->getMessage() . "\n" . $e->getTraceAsString());
            return response()->json(['error' => 'server error', 'message' => $e->getMessage()], 500);
        }
    }
}