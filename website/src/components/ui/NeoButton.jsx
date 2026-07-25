export default function NeoButton({
  children,
  variant,
  size,
  as: Component = 'button',
  className = '',
  ...props
}) {
  const classes = ['neo-btn', variant && `neo-btn--${variant}`, size && `neo-btn--${size}`, className]
    .filter(Boolean)
    .join(' ');

  return (
    <Component className={classes} {...props}>
      {children}
    </Component>
  );
}
