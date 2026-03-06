import React from 'react';
import {interpolate, useCurrentFrame} from 'remotion';

interface CodeBlockProps {
	code: string;
	language?: string;
	highlight?: number[];
}

export const CodeBlock: React.FC<CodeBlockProps> = ({code, language = 'go', highlight = []}) => {
	const frame = useCurrentFrame();

	const opacity = interpolate(frame, [0, 20], [0, 1]);

	const lines = code.split('\n');

	return (
		<div style={{opacity}}>
			<pre
				style={{
					background: '#1e293b',
					padding: 24,
					borderRadius: 12,
					color: '#cbd5e1',
					fontSize: 16,
					overflow: 'auto',
					lineHeight: 1.8,
					margin: 0,
					border: '1px solid #334155',
				}}
			>
				<code>
					{lines.map((line, idx) => (
						<div
							key={idx}
							style={{
								background: highlight.includes(idx) ? '#3b82f620' : 'transparent',
								paddingLeft: 12,
								marginLeft: -12,
							}}
						>
							{line}
						</div>
					))}
				</code>
			</pre>
		</div>
	);
};
