import React from 'react';
import {interpolate, useCurrentFrame} from 'remotion';

interface WorkflowStepProps {
	number: number;
	title: string;
	description: string;
	accentColor: string;
}

export const WorkflowStep: React.FC<WorkflowStepProps> = ({number, title, description, accentColor}) => {
	const frame = useCurrentFrame();

	const opacity = interpolate(frame, [0, 20], [0, 1]);

	return (
		<div
			style={{
				opacity,
				background: '#1e293b',
				padding: 24,
				borderRadius: 12,
				borderLeft: `4px solid ${accentColor}`,
			}}
		>
			<div style={{display: 'flex', alignItems: 'center', marginBottom: 12}}>
				<div
					style={{
						width: 32,
						height: 32,
						background: accentColor,
						borderRadius: '50%',
						display: 'flex',
						alignItems: 'center',
						justifyContent: 'center',
						color: '#fff',
						fontWeight: 'bold',
						marginRight: 12,
					}}
				>
					{number}
				</div>
				<h3 style={{color: '#fff', fontSize: 24, margin: 0}}>{title}</h3>
			</div>
			<p style={{color: '#cbd5e1', fontSize: 16, margin: 0}}>{description}</p>
		</div>
	);
};
