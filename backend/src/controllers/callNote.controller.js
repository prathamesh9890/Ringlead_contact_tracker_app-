const asyncHandler = require('../utils/asyncHandler');
const ApiResponse = require('../utils/ApiResponse');
const CallNote = require('../models/callNote.model');

// GET /api/notes — all of the signed-in business's call notes.
const listNotes = asyncHandler(async (req, res) => {
  const notes = await CallNote.find({ user: req.user._id }).sort({ updatedAt: -1 });
  res.status(200).json(new ApiResponse(200, notes.map((n) => n.toPublicProfile())));
});

// PUT /api/notes/:callKey — create or update the note for one call.
// An empty note deletes it, so clearing the field removes the record.
const upsertNote = asyncHandler(async (req, res) => {
  const { callKey } = req.params;
  const { note = '', number = '', name = '' } = req.body;

  if (!note.trim()) {
    await CallNote.deleteOne({ user: req.user._id, callKey });
    res.status(200).json(new ApiResponse(200, null, 'Note cleared'));
    return;
  }

  const saved = await CallNote.findOneAndUpdate(
    { user: req.user._id, callKey },
    { $set: { note: note.trim(), number, name } },
    { new: true, upsert: true, setDefaultsOnInsert: true },
  );
  res.status(200).json(new ApiResponse(200, saved.toPublicProfile(), 'Note saved'));
});

// DELETE /api/notes/:callKey
const deleteNote = asyncHandler(async (req, res) => {
  await CallNote.deleteOne({ user: req.user._id, callKey: req.params.callKey });
  res.status(200).json(new ApiResponse(200, null, 'Note deleted'));
});

module.exports = { listNotes, upsertNote, deleteNote };
