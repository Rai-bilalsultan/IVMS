/** @format */

import "./styles/AuthLink.css";

export default function AuthLinks({ leftText, leftTo, rightText, rightTo }) {
  return (
    <div className="auth-links">
      <a className="auth-link left" href={leftTo}>
        {leftText}
      </a>
      <a className="auth-link right" href={rightTo}>
        {rightText}
      </a>
    </div>
  );
}
