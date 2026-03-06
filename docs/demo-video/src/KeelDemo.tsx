import React from 'react';
import {
	AbsoluteFill,
	Sequence,
	useCurrentFrame,
	interpolate,
	Easing,
	spring,
} from 'remotion';
import {Title} from './components/Title';
import {CodeBlock} from './components/CodeBlock';
import {FileTree} from './components/FileTree';
import {WorkflowStep} from './components/WorkflowStep';

const backgroundColor = '#0f172a'; // slate-900
const accentColor = '#3b82f6'; // blue-500
const successColor = '#10b981'; // green-500

export const KeelDemo: React.FC = () => {
	const frame = useCurrentFrame();

	return (
		<AbsoluteFill style={{backgroundColor}}>
			{/* Title Sequence: 0-150 frames */}
			<Sequence from={0} durationInFrames={150}>
				<Title
					text="Keel"
					subtitle="Context Engine & Guardrail Installer for Claude Code"
					accentColor={accentColor}
				/>
			</Sequence>

			{/* Problem Statement: 150-300 frames */}
			<Sequence from={150} durationInFrames={150}>
				<ProblemStatement accentColor={accentColor} />
			</Sequence>

			{/* Solution: 300-450 frames */}
			<Sequence from={300} durationInFrames={150}>
				<Solution accentColor={accentColor} successColor={successColor} />
			</Sequence>

			{/* Workflow Demo: 450-750 frames */}
			<Sequence from={450} durationInFrames={300}>
				<WorkflowDemo accentColor={accentColor} successColor={successColor} />
			</Sequence>

			{/* Code Quality Example: 750-900 frames */}
			<Sequence from={750} durationInFrames={150}>
				<CodeQualityExample accentColor={accentColor} />
			</Sequence>
		</AbsoluteFill>
	);
};

const ProblemStatement: React.FC<{accentColor: string}> = ({accentColor}) => {
	return (
		<AbsoluteFill style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', padding: 60}}>
			<h1 style={{fontSize: 56, color: '#fff', marginBottom: 40, fontWeight: 'bold'}}>
				The Problem
			</h1>
			<div style={{fontSize: 32, color: '#cbd5e1', lineHeight: 1.6}}>
				<p>❌ Claude produces inconsistent code across projects</p>
				<p style={{marginTop: 20}}>❌ Magic numbers, weak error handling, missed security checks</p>
				<p style={{marginTop: 20}}>❌ Every project needs the same guardrails</p>
				<p style={{marginTop: 20}}>❌ Rules are documented but not enforced</p>
			</div>
		</AbsoluteFill>
	);
};

const Solution: React.FC<{accentColor: string; successColor: string}> = ({
	accentColor,
	successColor,
}) => {
	return (
		<AbsoluteFill style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', padding: 60}}>
			<h1 style={{fontSize: 56, color: successColor, marginBottom: 40, fontWeight: 'bold'}}>
				The Solution: Keel
			</h1>
			<div style={{fontSize: 32, color: '#cbd5e1', lineHeight: 1.8}}>
				<p>✓ Define rules once as markdown files</p>
				<p style={{marginTop: 20}}>✓ Claude reads rules automatically</p>
				<p style={{marginTop: 20}}>✓ Generate config, soul, and guardrails</p>
				<p style={{marginTop: 20}}>✓ Same standards across your entire team</p>
			</div>
		</AbsoluteFill>
	);
};

const WorkflowDemo: React.FC<{accentColor: string; successColor: string}> = ({
	accentColor,
	successColor,
}) => {
	return (
		<AbsoluteFill style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', padding: 60}}>
			<h1 style={{fontSize: 48, color: '#fff', marginBottom: 60, fontWeight: 'bold'}}>
				Keel Workflow
			</h1>

			<div style={{display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 40, fontSize: 24}}>
				{/* Step 1 */}
				<div style={{background: '#1e293b', padding: 30, borderRadius: 12, borderLeft: `4px solid ${accentColor}`}}>
					<h3 style={{color: accentColor, marginBottom: 15}}>1. /keel:init</h3>
					<p style={{color: '#cbd5e1'}}>Detect project, audit stack, generate config</p>
				</div>

				{/* Step 2 */}
				<div style={{background: '#1e293b', padding: 30, borderRadius: 12, borderLeft: `4px solid ${accentColor}`}}>
					<h3 style={{color: accentColor, marginBottom: 15}}>2. Rules Installed</h3>
					<p style={{color: '#cbd5e1'}}>Base, language, and framework rules auto-load</p>
				</div>

				{/* Step 3 */}
				<div style={{background: '#1e293b', padding: 30, borderRadius: 12, borderLeft: `4px solid ${accentColor}`}}>
					<h3 style={{color: accentColor, marginBottom: 15}}>3. /keel:plan</h3>
					<p style={{color: '#cbd5e1'}}>Create phased plans with rule-aware prompts</p>
				</div>

				{/* Step 4 */}
				<div style={{background: '#1e293b', padding: 30, borderRadius: 12, borderLeft: `4px solid ${accentColor}`}}>
					<h3 style={{color: accentColor, marginBottom: 15}}>4. Execute</h3>
					<p style={{color: '#cbd5e1'}}>Claude reads rules and produces guardrailed code</p>
				</div>
			</div>

			<div style={{marginTop: 60, padding: 20, background: successColor + '20', borderRadius: 12, borderLeft: `4px solid ${successColor}`}}>
				<p style={{color: successColor, fontSize: 24, fontWeight: 'bold'}}>Result: Production-grade code, every time</p>
			</div>
		</AbsoluteFill>
	);
};

const CodeQualityExample: React.FC<{accentColor: string}> = ({accentColor}) => {
	return (
		<AbsoluteFill style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', padding: 60}}>
			<h1 style={{fontSize: 48, color: '#fff', marginBottom: 40, fontWeight: 'bold'}}>
				Rule Example: No Magic Numbers
			</h1>

			<div style={{display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 40}}>
				{/* Bad */}
				<div>
					<h3 style={{color: '#ef4444', marginBottom: 20}}>Without Rules ❌</h3>
					<pre
						style={{
							background: '#1e293b',
							padding: 20,
							borderRadius: 8,
							color: '#cbd5e1',
							fontSize: 14,
							overflow: 'auto',
							lineHeight: 1.6,
						}}
					>
{`const token = jwt.sign({
  userId: user.id,
  exp: Date.now() + 86400000
});`}
					</pre>
					<p style={{color: '#fed7aa', marginTop: 15, fontSize: 16}}>Magic number: 86400000</p>
				</div>

				{/* Good */}
				<div>
					<h3 style={{color: '#10b981', marginBottom: 20}}>With Keel Rules ✓</h3>
					<pre
						style={{
							background: '#1e293b',
							padding: 20,
							borderRadius: 8,
							color: '#cbd5e1',
							fontSize: 14,
							overflow: 'auto',
							lineHeight: 1.6,
						}}
					>
{`const TokenExpiryHours = 24;
const TokenExpiry = () =>
  time.Duration(TokenExpiryHours) * time.Hour;

token := jwt.Sign({
  userId: user.id,
  exp: now + TokenExpiry()
})`}
					</pre>
					<p style={{color: '#86efac', marginTop: 15, fontSize: 16}}>Named constant enforced</p>
				</div>
			</div>
		</AbsoluteFill>
	);
};
