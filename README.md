# Billing System React App

A modern React billing system built with Vite, React Router DOM, and Tailwind CSS.

## Features

- **HomePage**: Navigation hub with two main buttons
- **ItemListPage**: Displays scanned items with prices and total
- **ItemEntryPage**: Form for manual item entry
- **Responsive Design**: Mobile-first approach with Tailwind CSS
- **React Router**: Client-side routing between pages

## Getting Started

### Prerequisites
- Node.js (version 16 or higher)
- npm or yarn

### Installation

1. Install dependencies:
```bash
npm install
```

2. Start the development server:
```bash
npm run dev
```

3. Open your browser and navigate to `http://localhost:5173`

### Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build
- `npm run lint` - Run ESLint

## Project Structure

```
src/
├── components/
│   ├── HomePage.jsx          # Main navigation page
│   ├── ItemListPage.jsx      # Item list with total
│   └── ItemEntryPage.jsx     # Manual item entry form
├── styles/
│   └── global.css            # Global styles with Tailwind
├── App.jsx                   # Main app with routing
└── main.jsx                  # Entry point
```

## Technologies Used

- **React 18** - UI library
- **Vite** - Build tool and dev server
- **React Router DOM** - Client-side routing
- **Tailwind CSS** - Utility-first CSS framework
- **ESLint** - Code linting