import { NavLink } from 'react-router-dom';
import NeoCard from '../../components/ui/NeoCard';
import NeoButton from '../../components/ui/NeoButton';

const plans = [
  {
    name: 'Free',
    price: '$0',
    tagline: 'For solo businesses getting started',
    features: ['Missed-call logging', '1 team member', 'Basic contact history', 'Email support'],
    variant: undefined,
  },
  {
    name: 'Pro',
    price: '$29/mo',
    tagline: 'For growing teams that can’t afford a missed lead',
    features: [
      'Everything in Free',
      'Unlimited team members',
      'One-tap follow-up reminders',
      'Team dashboard & analytics',
      'Priority support',
    ],
    variant: 'primary',
    highlighted: true,
  },
];

export default function Pricing() {
  return (
    <section className="container" style={{ paddingTop: 56, paddingBottom: 96 }}>
      <div className="neo-stack" style={{ alignItems: 'center', textAlign: 'center', gap: 12, marginBottom: 48 }}>
        <h1 style={{ fontSize: 40, fontWeight: 800 }}>Simple, honest pricing</h1>
        <p className="text-muted" style={{ fontSize: 17 }}>Start free. Upgrade when your team grows.</p>
      </div>

      <div
        style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))',
          gap: 32,
          maxWidth: 760,
          margin: '0 auto',
        }}
      >
        {plans.map((plan) => (
          <NeoCard
            key={plan.name}
            className="neo-stack"
            inset={plan.highlighted}
            style={{ gap: 20, border: plan.highlighted ? '2px solid var(--accent)' : 'none' }}
          >
            <div className="neo-stack" style={{ gap: 4 }}>
              <h2 style={{ fontSize: 22, fontWeight: 800 }}>{plan.name}</h2>
              <p className="text-muted">{plan.tagline}</p>
            </div>
            <div style={{ fontSize: 36, fontWeight: 800 }}>{plan.price}</div>
            <ul className="neo-stack" style={{ gap: 10, listStyle: 'none', padding: 0 }}>
              {plan.features.map((f) => (
                <li key={f} className="neo-row" style={{ gap: 10 }}>
                  <span style={{ color: 'var(--accent-2)', fontWeight: 700 }}>✓</span>
                  <span>{f}</span>
                </li>
              ))}
            </ul>
            <NeoButton as={NavLink} to="/contact" variant={plan.variant}>
              Choose {plan.name}
            </NeoButton>
          </NeoCard>
        ))}
      </div>
    </section>
  );
}
