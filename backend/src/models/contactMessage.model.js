const mongoose = require('mongoose');

const contactMessageSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true,
    },
    email: {
      type: String,
      required: true,
      lowercase: true,
      trim: true,
    },
    message: {
      type: String,
      required: true,
      trim: true,
    },
    status: {
      type: String,
      enum: ['new', 'resolved'],
      default: 'new',
    },
  },
  { timestamps: true },
);

contactMessageSchema.methods.toPublicProfile = function toPublicProfile() {
  return {
    id: this._id.toString(),
    name: this.name,
    email: this.email,
    message: this.message,
    status: this.status,
    createdAt: this.createdAt,
  };
};

module.exports = mongoose.model('ContactMessage', contactMessageSchema);
