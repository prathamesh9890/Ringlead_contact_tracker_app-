import { NavLink } from 'react-router-dom';
import NeoCard from '../../components/ui/NeoCard';
import NeoButton from '../../components/ui/NeoButton';

const features = [
  {
    title: 'Instant missed-call alerts',
    desc: 'The moment a call is missed, Ringlead logs it and notifies your team so no lead slips through.',
    icon: '📞',
  },
  {
    title: 'One-tap follow-up',
    desc: 'Turn a missed call into a text or callback reminder in a single tap, right from the contact card.',
    icon: '⚡',
  },
  {
    title: 'Team dashboard',
    desc: 'See every business number, call volume, and response time in one soft, glanceable dashboard.',
    icon: '📊',
  },
  {
    title: 'Works with your number',
    desc: 'No porting, no new hardware. Ringlead layers on top of the phone number you already use.',
    icon: '🔌',
  },
];

export default function Home() {
  return (
    <div className="neo-stack" style={{ gap: 96, paddingBottom: 96 }}>
      <section className="container" style={{ paddingTop: 56 }}>
        <div className="neo-stack" style={{ alignItems: 'center', textAlign: 'center', gap: 28 }}>
          <span className="neo-badge">Built for small business teams</span>
          <h1 style={{ fontSize: 52, fontWeight: 800, maxWidth: 720, lineHeight: 1.15 }}>
            Never miss a lead again.
          </h1>
          <p className="text-muted" style={{ fontSize: 19, maxWidth: 560 }}>
            Ringlead tracks every missed call and turns it into a follow-up task, so busy teams stop losing
            business to voicemail.
          </p>
          <div className="neo-row">
            <NeoButton as={NavLink} to="/pricing" variant="primary">
              See pricing
            </NeoButton>
            <NeoButton as={NavLink} to="/contact">
              Talk to us
            </NeoButton>
          </div>
        </div>
      </section>

      <section className="container">
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))',
            gap: 24,
          }}
        >
          {features.map((f) => (
            <NeoCard key={f.title} className="neo-stack" style={{ gap: 14 }}>
              <div className="neo-inset" style={{ width: 52, height: 52, display: 'grid', placeItems: 'center', fontSize: 22 }}>
                {f.icon}
              </div>
              <h3 style={{ fontSize: 18, fontWeight: 700 }}>{f.title}</h3>
              <p className="text-muted" style={{ fontSize: 15 }}>
                {f.desc}
              </p>
            </NeoCard>
          ))}
        </div>
      </section>

      <section className="container">
        <NeoCard
          className="neo-row"
          style={{ justifyContent: 'space-between', flexWrap: 'wrap', gap: 24, padding: 40 }}
        >
          <div className="neo-stack" style={{ gap: 8 }}>
            <h2 style={{ fontSize: 26, fontWeight: 800 }}>Ready to stop losing calls?</h2>
            <p className="text-muted">Start free — upgrade to Pro whenever your team is ready.</p>
          </div>
          <NeoButton as={NavLink} to="/pricing" variant="primary">
            Get started
          </NeoButton>
        </NeoCard>
      </section>
    </div>
  );
}
