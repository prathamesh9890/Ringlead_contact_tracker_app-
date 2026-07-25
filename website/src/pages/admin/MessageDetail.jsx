import { useEffect, useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import api, { apiErrorMessage } from '../../api/client';
import NeoCard from '../../components/ui/NeoCard';
import NeoButton from '../../components/ui/NeoButton';
import NeoBadge from '../../components/ui/NeoBadge';
import Spinner from '../../components/ui/Spinner';

export default function MessageDetail() {
  const { id } = useParams();
  const [message, setMessage] = useState(null);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [saved, setSaved] = useState(false);

  useEffect(() => {
    let cancelled = false;
    api
      .get(`/admin/contacts/${id}`)
      .then(({ data }) => {
        if (!cancelled) setMessage(data.data);
      })
      .catch((err) => {
        if (!cancelled) setError(apiErrorMessage(err, 'Failed to load message'));
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });
    return () => {
      cancelled = true;
    };
  }, [id]);

  async function toggleResolved() {
    setSaving(true);
    setSaved(false);
    try {
      const nextStatus = message.status === 'new' ? 'resolved' : 'new';
      const { data } = await api.patch(`/admin/contacts/${id}`, { status: nextStatus });
      setMessage(data.data);
      setSaved(true);
    } catch (err) {
      setError(apiErrorMessage(err, 'Failed to update message'));
    } finally {
      setSaving(false);
    }
  }

  if (loading) return <Spinner label="Loading message…" />;
  if (error && !message) {
    return (
      <div className="neo-stack" style={{ gap: 16 }}>
        <p className="text-danger">{error}</p>
        <Link to="/admin/messages">
          <NeoButton size="sm">Back to messages</NeoButton>
        </Link>
      </div>
    );
  }

  return (
    <div className="neo-stack" style={{ gap: 24, maxWidth: 640 }}>
      <div className="neo-row" style={{ justifyContent: 'space-between' }}>
        <div>
          <Link to="/admin/messages" className="text-muted" style={{ fontSize: 14 }}>
            ← Back to messages
          </Link>
          <h1 style={{ fontSize: 26, fontWeight: 800, marginTop: 8 }}>{message.name}</h1>
        </div>
        <NeoBadge variant={message.status === 'new' ? 'active' : ''}>
          {message.status === 'new' ? 'New' : 'Resolved'}
        </NeoBadge>
      </div>

      <NeoCard className="neo-stack" style={{ gap: 20 }}>
        <div>
          <div className="text-muted" style={{ fontSize: 13 }}>Email</div>
          <div style={{ fontWeight: 600 }}>{message.email}</div>
        </div>
        <div>
          <div className="text-muted" style={{ fontSize: 13 }}>Received</div>
          <div style={{ fontWeight: 600 }}>{new Date(message.createdAt).toLocaleString()}</div>
        </div>
        <div>
          <div className="text-muted" style={{ fontSize: 13, marginBottom: 6 }}>Message</div>
          <div className="neo-inset" style={{ padding: 16, whiteSpace: 'pre-wrap', lineHeight: 1.5 }}>
            {message.message}
          </div>
        </div>

        {error && <p className="text-danger">{error}</p>}
        {saved && !saving && <p style={{ color: 'var(--accent-2)', fontSize: 14 }}>Saved.</p>}

        <NeoButton variant={message.status === 'new' ? 'primary' : undefined} disabled={saving} onClick={toggleResolved}>
          {saving ? 'Saving…' : message.status === 'new' ? 'Mark as resolved' : 'Reopen as new'}
        </NeoButton>
      </NeoCard>
    </div>
  );
}
