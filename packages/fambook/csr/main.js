import { StrictMode } from 'react';
import React from 'react';
import { createRoot } from 'react-dom/client';
import App from "@melange/App.js";

const rootElement = document.getElementById('root');
const root = createRoot(rootElement);

root.render(
  React.createElement(StrictMode, {}, React.createElement(App))
);
