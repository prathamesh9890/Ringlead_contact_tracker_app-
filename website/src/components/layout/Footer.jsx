export default function Footer() {
  return (
    <footer style={{ padding: '48px 0 32px' }}>
      <div className="container neo-row" style={{ justifyContent: 'space-between' }}>
        <span className="text-muted">© {new Date().getFullYear()} Ringlead. All rights reserved.</span>
        <span className="text-muted">Never miss a lead again.</span>
      </div>
    </footer>
  );
}
