import React from 'react';
import {Composition, registerRoot} from 'remotion';
import {KeelDemo} from './KeelDemo';

export const RemotionRoot: React.FC = () => {
	return (
		<Composition
			id="Keel"
			component={KeelDemo}
			durationInFrames={900}
			fps={30}
			width={1920}
			height={1080}
		/>
	);
};

registerRoot(RemotionRoot);
