/** Logo Primes Services (« P » en trois quarts de cercle), redessiné en SVG vectoriel. */
export function LogoMark({ className = "h-9 w-9", color = "currentColor" }: { className?: string; color?: string }) {
  return (
    <svg viewBox="440 470 1000 1020" className={className} role="img" aria-label="Logo Primes Services" fill={color}>
      <path d="M776 486H1100A318 320 0 0 1 1418 806H1100A324 320 0 0 1 776 486Z" />
      <path d="M1418 837H1100A324 319 0 0 0 776 1156H1100A318 319 0 0 0 1418 837Z" />
      <path d="M456 1156H776A320 320 0 0 1 456 1476Z" />
    </svg>
  );
}
