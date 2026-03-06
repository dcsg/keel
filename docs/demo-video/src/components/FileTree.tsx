import React from 'react';
import {interpolate, useCurrentFrame} from 'remotion';

interface FileTreeProps {
	files: {name: string; indent: number}[];
}

export const FileTree: React.FC<FileTreeProps> = ({files}) => {
	const frame = useCurrentFrame();

	const opacity = interpolate(frame, [0, 30], [0, 1]);

	return (
		<div style={{opacity, fontFamily: 'monospace'}}>
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
				{files.map((file, idx) => (
					<div key={idx} style={{paddingLeft: `${file.indent * 20}px`}}>
						{file.indent > 0 ? '├── ' : ''}{file.name}
					</div>
				))}
			</pre>
		</div>
	);
};
