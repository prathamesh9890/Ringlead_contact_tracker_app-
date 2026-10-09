const asyncHandler = require('../utils/asyncHandler');
const ApiResponse = require('../utils/ApiResponse');
const CallNote = require('../models/callNote.model');

// GET /api/notes — all of the signed-in business's call notes.
const listNotes = asyncHandler(async (req, res) => {
  const notes = await CallNote.find({ user: req.user._id }).sort({ updatedAt: -1 });
  res.status(200).json(new ApiResponse(200, notes.map((n) => n.toPublicProfile())));
});

// PUT /api/notes/:callKey — create or update the note and/or lead status for a
// call. When both the note and status are empty, the record is removed.
const upsertNote = asyncHandler(async (req, res) => {
  const { callKey } = req.params;
  const { note = '', number = '', name = '', status = 'none' } = req.body;
  const trimmedNote = note.trim();

  if (!trimmedNote && (!status || status === 'none')) {
    await CallNote.deleteOne({ user: req.user._id, callKey });
    res.status(200).json(new ApiResponse(200, null, 'Note cleared'));
    return;
  }

  const saved = await CallNote.findOneAndUpdate(
    { user: req.user._id, callKey },
    { $set: { note: trimmedNote, number, name, status } },
    { new: true, upsert: true, setDefaultsOnInsert: true },
  );
  res.status(200).json(new ApiResponse(200, saved.toPublicProfile(), 'Saved'));
});

// DELETE /api/notes/:callKey
const deleteNote = asyncHandler(async (req, res) => {
  await CallNote.deleteOne({ user: req.user._id, callKey: req.params.callKey });
  res.status(200).json(new ApiResponse(200, null, 'Note deleted'));
});

module.exports = { listNotes, upsertNote, deleteNote };
