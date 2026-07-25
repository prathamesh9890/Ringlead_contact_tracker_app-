import { NavLink } from 'react-router-dom';
import NeoButton from '../components/ui/NeoButton';

export default function NotFound() {
  return (
    <div
      className="container neo-stack"
      style={{ minHeight: '100%', alignItems: 'center', justifyContent: 'center', textAlign: 'center', gap: 16 }}
    >
      <h1 style={{ fontSize: 64, fontWeight: 800 }}>404</h1>
      <p className="text-muted">This page doesn’t exist.</p>
      <NeoButton as={NavLink} to="/" variant="primary">
        Back home
      </NeoButton>
    </div>
  );
}
