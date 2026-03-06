import React from 'react';
import {AbsoluteFill, interpolate, useCurrentFrame, Easing} from 'remotion';

interface TitleProps {
	text: string;
	subtitle: string;
	accentColor: string;
}

export const Title: React.FC<TitleProps> = ({text, subtitle, accentColor}) => {
	const frame = useCurrentFrame();

	const titleScale = interpolate(frame, [0, 30], [0.5, 1], {
		easing: Easing.out(Easing.cubic),
	});

	const titleOpacity = interpolate(frame, [0, 20], [0, 1]);

	const subtitleOpacity = interpolate(frame, [40, 60], [0, 1]);

	return (
		<AbsoluteFill style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center'}}>
			<div
				style={{
					transform: `scale(${titleScale})`,
					opacity: titleOpacity,
				}}
			>
				<h1
					style={{
						fontSize: 120,
						color: accentColor,
						fontWeight: 'bold',
						margin: 0,
						letterSpacing: -2,
					}}
				>
					{text}
				</h1>
			</div>

			<div style={{opacity: subtitleOpacity, marginTop: 40}}>
				<p
					style={{
						fontSize: 40,
						color: '#cbd5e1',
						textAlign: 'center',
						margin: 0,
						maxWidth: 1200,
					}}
				>
					{subtitle}
				</p>
			</div>
		</AbsoluteFill>
	);
};
