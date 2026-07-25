export default function Spinner({ label }) {
  return (
    <div className="neo-row" style={{ justifyContent: 'center', padding: '40px 0' }}>
      <span className="neo-spinner" />
      {label && <span className="text-muted">{label}</span>}
    </div>
  );
}
