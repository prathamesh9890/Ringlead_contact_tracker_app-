import { useState } from 'react';
import api, { apiErrorMessage } from '../../api/client';
import NeoCard from '../../components/ui/NeoCard';
import NeoButton from '../../components/ui/NeoButton';
import NeoInput, { NeoField } from '../../components/ui/NeoInput';

const initialForm = { name: '', email: '', message: '' };

export default function Contact() {
  const [form, setForm] = useState(initialForm);
  const [sent, setSent] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState('');

  function handleChange(e) {
    setForm((prev) => ({ ...prev, [e.target.name]: e.target.value }));
  }

  async function handleSubmit(e) {
    e.preventDefault();
    setSubmitting(true);
    setError('');
    try {
      await api.post('/contact', form);
      setSent(true);
    } catch (err) {
      setError(apiErrorMessage(err, 'Failed to send your message — please try again.'));
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <section className="container" style={{ paddingTop: 56, paddingBottom: 96, maxWidth: 640 }}>
      <div className="neo-stack" style={{ gap: 8, marginBottom: 32, textAlign: 'center' }}>
        <h1 style={{ fontSize: 36, fontWeight: 800 }}>Talk to us</h1>
        <p className="text-muted">Questions about Ringlead or Pro plans? Send us a note.</p>
      </div>

      <NeoCard>
        {sent ? (
          <div className="neo-stack" style={{ alignItems: 'center', textAlign: 'center', gap: 12, padding: '24px 0' }}>
            <span style={{ fontSize: 40 }}>✅</span>
            <h3 style={{ fontSize: 20, fontWeight: 700 }}>Thanks, {form.name.split(' ')[0] || 'there'}!</h3>
            <p className="text-muted">We received your message and will get back to you shortly.</p>
          </div>
        ) : (
          <form className="neo-stack" style={{ gap: 20 }} onSubmit={handleSubmit}>
            <NeoField label="Name">
              <NeoInput name="name" value={form.name} onChange={handleChange} placeholder="Jane Doe" required />
            </NeoField>
            <NeoField label="Email">
              <NeoInput
                type="email"
                name="email"
                value={form.email}
                onChange={handleChange}
                placeholder="jane@business.com"
                required
              />
            </NeoField>
            <NeoField label="Message">
              <textarea
                className="neo-input"
                name="message"
                rows={5}
                value={form.message}
                onChange={handleChange}
                placeholder="How can we help?"
                required
              />
            </NeoField>
            {error && <p className="text-danger" style={{ margin: 0 }}>{error}</p>}
            <NeoButton type="submit" variant="primary" disabled={submitting}>
              {submitting ? 'Sending…' : 'Send message'}
            </NeoButton>
          </form>
        )}
      </NeoCard>
    </section>
  );
}
