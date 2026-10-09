const mongoose = require('mongoose');

// A note a business attaches to one specific call. Calls themselves live on the
// device (the phone's call log), so each note is linked to its call by
// `callKey` — the call's timestamp in milliseconds, as a string.
const callNoteSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    callKey: {
      type: String,
      required: true,
      trim: true,
    },
    number: {
      type: String,
      trim: true,
      default: '',
    },
    name: {
      type: String,
      trim: true,
      default: '',
    },
    note: {
      type: String,
      trim: true,
      default: '',
    },
  },
  { timestamps: true },
);

// One note per call, per business.
callNoteSchema.index({ user: 1, callKey: 1 }, { unique: true });

callNoteSchema.methods.toPublicProfile = function toPublicProfile() {
  return {
    callKey: this.callKey,
    number: this.number,
    name: this.name,
    note: this.note,
    updatedAt: this.updatedAt,
  };
};

module.exports = mongoose.model('CallNote', callNoteSchema);
