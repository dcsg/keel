# Generating the Keel Demo Video

The Keel demo video is built with **Remotion** — a React framework for generating videos programmatically. It's a 30-second polished demo showing keel's workflow.

## Quick Start

### 1. Install Dependencies

```bash
cd docs/demo-video
npm install
```

### 2. Preview

```bash
npm run dev
```

Opens browser at http://localhost:3000 with live preview.

### 3. Render to MP4

```bash
npm run build
```

Outputs `demo.mp4` (1920×1080, 30fps, ~30 seconds).

## Video Scenes

| Time | Scene | Duration |
|------|-------|----------|
| 0-5s | Title intro "Keel" | 5s |
| 5-10s | Problem statement | 5s |
| 10-15s | Solution benefits | 5s |
| 15-25s | Workflow demo (4 steps) | 10s |
| 25-30s | Code quality example | 5s |

## Structure

```
docs/demo-video/
├── src/
│   ├── index.tsx               # Entry point
│   ├── KeelDemo.tsx            # Main 5-scene composition
│   └── components/
│       ├── Title.tsx           # Fade-in + scale animations
│       ├── CodeBlock.tsx        # Syntax highlighting
│       ├── FileTree.tsx         # Directory structure display
│       └── WorkflowStep.tsx     # Step cards
├── tsconfig.json
└── package.json
```

## Customization

### Change Colors

Edit `src/KeelDemo.tsx`:

```typescript
const backgroundColor = '#0f172a';  // Dark slate
const accentColor = '#3b82f6';      // Keel blue
const successColor = '#10b981';     // Success green
```

### Adjust Timings

Each scene is a `Sequence` with `durationInFrames`:

```typescript
// 150 frames @ 30fps = 5 seconds
<Sequence from={0} durationInFrames={150}>
  <Title ... />
</Sequence>

// 300 frames @ 30fps = 10 seconds
<Sequence from={450} durationInFrames={300}>
  <WorkflowDemo ... />
</Sequence>
```

### Edit Text

Update components directly:

- `Title.tsx` → Change "Keel" title or subtitle
- `KeelDemo.tsx` → Change problem points, benefits, workflow steps

## Output Formats

### MP4 (Recommended)

```bash
npm run build
# Outputs: docs/demo-video/demo.mp4
```

### WebM (Lower bandwidth)

```bash
npx remotion render src/index.tsx Keel demo.webm --codec=vp9
```

### GIF Preview

```bash
npx remotion render src/index.tsx Keel demo.gif --sequence
```

## Publishing

### Add to README

```markdown
## Quick Demo

![Keel workflow demo](./docs/demo-video/demo.mp4)
```

### Add to Getting Started Guide

```markdown
## See It in Action

<video width="100%" controls style="border-radius: 8px;">
  <source src="/docs/demo-video/demo.mp4" type="video/mp4">
  Your browser doesn't support HTML5 video.
</video>

The video shows:
1. Running `/keel:init` on a new project
2. Rules automatically installing
3. Creating a phased plan with `/keel:plan`
4. Claude executing with guardrails enforced
```

## Requirements

- **Node.js** 16+ (check with `node --version`)
- **npm** 7+ (check with `npm --version`)
- Rendering is CPU-intensive (takes 1-5 minutes depending on hardware)

## Pro Tips

### High-quality render

```bash
npx remotion render -q high src/index.tsx Keel demo-hq.mp4
```

### Specific resolution

```bash
npx remotion render --width 1280 --height 720 src/index.tsx Keel demo-720p.mp4
```

### Faster preview (lower quality)

```bash
npm run dev -- --quality=25
```

## Troubleshooting

**Error: "FFmpeg not found"**

```bash
npx remotion still src/index.tsx Keel frame.png
```

This verifies Remotion is set up correctly.

**Video not rendering**

Check console output for specific error. Common causes:
- Node version < 16
- Missing dependencies: `npm install`
- Out of disk space
- System running low on memory (close other apps)

## Next Steps

1. Run `npm run build` to generate `demo.mp4`
2. Copy to root docs folder (if desired): `cp demo.mp4 ../../`
3. Update README with the video link
4. Commit to git: `git add docs/demo-video/ docs/demo-video/demo.mp4`
