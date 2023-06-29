import { expect } from 'chai';
import { ethers, deployments, getUnnamedAccounts } from 'hardhat';
import { IERC735 } from '../typechain-types';
import { setupUser, setupUsers } from './utils';

const setup = deployments.createFixture(async () => {
	await deployments.fixture('ERC735');
	const contracts = {
		ERC735: await ethers.getContract<IERC735>('ERC735'),
	};
	const users = await setupUsers(await getUnnamedAccounts(), contracts);
	return {
		...contracts,
		users,
	};
});

describe('ERC735', function () {
	it('addClaim, getClaim, changeClaim, removeClaim', async function () {
		const { users, ERC735 } = await setup();
		const topic = 1;
		const scheme = 1;
		const issuer = users[0].address;
		const signature = "0x123";
		const data = "0x123";
		const uri = "uri";

		// Add claim
		const claimRequestId = await ERC735.connect(users[0].ERC735 as any).addClaim(topic, scheme, issuer, signature, data, uri);

		await expect(ERC735.addClaim(topic, scheme, issuer, signature, data, uri))
			.to.emit(ERC735, 'ClaimRequested')
			.withArgs(claimRequestId, topic, scheme, issuer, signature, data, uri);

		// Get claim
		const claim = await ERC735.getClaim(claimRequestId as any);
		expect(claim).to.include({
			topic: topic,
			scheme: scheme,
			issuer: issuer,
			signature: signature,
			data: data,
			uri: uri
		});

		// Change claim
		const newSignature = "0x456";
		const newData = "0x456";
		const newUri = "uri2";
		await expect(ERC735.connect(users[0].ERC735 as any).changeClaim(claimRequestId as any, topic, scheme, issuer, newSignature, newData, newUri))
			.to.emit(ERC735, 'ClaimChanged')
			.withArgs(claimRequestId, topic, scheme, issuer, newSignature, newData, newUri);

		// Remove claim
		await expect(ERC735.connect(users[0].ERC735 as any).removeClaim(claimRequestId as any))
			.to.emit(ERC735, 'ClaimRemoved')
			.withArgs(claimRequestId, topic, scheme, issuer, signature, data, uri);
	});
});