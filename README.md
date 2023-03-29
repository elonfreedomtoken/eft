# eft
Elon Freedom token, or EFT, is a token that aims to be a community driven
token capable of disrupting social media through an incentivized series of token
burns and staking rewards. EFT is a community driven token that aims to empower
its users to inject their collective ideas into the discourse of social media
platforms. EFT aims to disrupt these platforms dominated by corporations
influencing the general discourse as well as individuals acting as their own agents
in self interest to create a community that will act together on their own interests,
creating a voice that is amplified. For this to happen, EFT recognizes the structure
of which social media platforms are based is one in which engagement is crucial
for their success, whether that be by posting content or interacting with content, to
name just a few. Leveraging this engagement is the key to EFT and democratizing
the social aspect of social media. This is what we term Incentivized Participation.
#Our Contract
There are 2 versions of the same contract, one is the flattened file published to the Andromeda network of Metis. The second is just our code without any of the libraries we import. 
# contract address <a href="https://andromeda-explorer.metis.io/address/0xfBc5f9Ac39419ec9ca6959A3Cb1667edE45201f5">0xfBc5f9Ac39419ec9ca6959A3Cb1667edE45201f5</a>

<h2>Basic Breakdown of the Contract</h2>
Tokenomic Terms Elaborated
<h3>ICO</h3>
The ICO will last one month from the time of publishing the dap on the Metis
chain. Up for sale is 25% of the total initial supply of 10,000,000 tokens. During
this time, the community may join and help promote the ICO by tweeting the
hashtag #EFT-ICO and thus contributing to the first burn {see Burn phase 1}. At
the completion of the ICO, what is left unsold of the 2,500,000 will be minted and
burned immediately by way of being hard coded in the contract.
<h3>Liquidity Pool</h3>
Furthermore, half of all funds received will be used to create a liquidity pool on
Netswap. Thus, up to 8.2% of the Initial total supply will be minted and sent with
the corresponding Metis received from the ICO. What this means is the price of
EFT will be raised by 50% post-ICO. This is meant to encourage buying EFT
during the ICO period. The Liquidity Pool will be created no later than 12 hours
after the ending of the ICO.What is left unminted for the Liquidity pool will be burned. To ensure fairness, the
tokens that are burned from the ICO will be reflected in the remaining unminted
supply by burning the same ratio we will refer to as Sold-Ratio.
<h3>Sold-Ratio</h3>
This is calculated by the number of tokens sold divided by the number of tokens
that were initially for sale.
Sold-Ratio = Sold / Initial_Supply
As an example, if only half of EFT ICO is sold, the sold-ratio is 1/2 and thus the
remaining supply of EFT will be reduced by that amount. {See here to look at the
contract}. The sold-ratio is seen as a way to keep the community buoyant and
ensure fairness is reflected in the supply and rest of the Phases going forward.
<h3>Burn Phase 1</h3>
The ICO Burn Phase will begin and last the length of the ICO – 1 month. This
phase has the potential to burn1,000,000 tokens of an initial 10,000,000 supply.
This equates to 10% of total initial supply. The burn will be directly related to the
amount of tweets containing the hashtag #EFT_ICO. The aim of this phase is to
offer an incentivized engagement program to promote the project. The total
amount of tweets containing #EFT_ICO counting toward the burn will be capped
at 2000, thus at or more than 2000 will complete the burn. The formula for the
burn will be a simple ratio of 1 tweet burns 500 tokens, again capped at 2000
tweets and 1,000,000 EFT. Whatever is not burned of the 1,000,000 tokens, will
trickle down to the Staking Phase.
<h3>Burn Phase 2</h3>
The incentivized nature of this phase will work in concert with voting. The initial
role of voting is cited in greater detail here{see voting}. This phase will have a
maximum amount of 15% of the total supply post ICO. After the voting/tweeting
period ends, an oracle will parse and count the relevant number of social media
engagements. The mechanism for burning is elaborated more here{see difficulty}.
In short, our algorithm for burning will take into consideration the number of
holders of the token and what the expected number of participation would be based
on those numbers. We aim to make this adjust smoothly dependent on participants,
but also to lag behind as well. We hope that this would encourage those to
continue to keep engaging thus allowing for more tokens to be burned at a faster
rate. This phase will last 4 months, starting immediately at the end of the ICO.Burn Phase 3
This phase is almost the same as Burn Phase 2 but will last 6 months. Some
differences include a modification of the burn algorithm and/or the inclusion of
other social media platforms. This is dependent upon development and may change
as development progresses.
<h3>Staking Phase</h3>
The last phase of Incentivized Participation involves staking. By staking tokens
one may earn a percentage of tokens released based on the involvement of the
community and the number of tokens they have staked. The potential for earnings
will be determined later and involves the coordination across media platforms and
the inclusion of community oracles. The amount of tokens for this phase will be
11.3% of the Post-ICO supply plus any residual tokens from Phases 1,2 and 3. This
is the final phase and will last for an extended period of time, preferably 5-10
years.
<h3>Voting</h3>
Voting will take place on the website, www.elonfreedomtoken.com/voting and
begin once the ICO ends. Voting will last 2 days. Anyone who owns EFTs may
vote by signing a message with their choice of hashtag they want the community to
vote on. They may choose a unique hashtag or one that has already been placed.
Voting will use a signed message and use balances associated with the address up
to but not after the current voting period. Voting power is based on the number of
tokens owned. This mechanism by which voting occurs may change as it may be
more preferable to conduct voting on chain, however, the very nature of voting
will remain.
<h3>Burn/Stake rate per engagement</h3>
The burn/stake rate per engagement will be different for each of the phases.
Burn Phase 1 will have a flat burn rate of per tweet containing the hashtag
#EFT-ICO. Up to 1 million tokens are eligible to be burnt. The formula for the
burn will be a simple ratio of 1 tweet burns 500 tokens, again capped at 2000
tweets and 1,000,000 EFT
Burn Phase 2 will adjust its burn rate in accordance to the number of token holders
as well as the expected number of engagements. To find the expected number we
will use a Kalman filter to find the expected number of tweets or E[tweets]. The
Kalman filter will act as a loose trailing metric that will adjust fairly quickly to the
current environment. The idea is to allow for it to work without many data pointsbut also to be robust enough to allow for a pretty good estimation of the next burn
rate.

<h4>Further fine tuned breakdown</h4>​

![infographicannotated](https://user-images.githubusercontent.com/129238833/228604719-5b4778bf-3682-4e28-9948-ffdc3ca482ad.png)
</br>A) Total initial supply---10,000,000
</br>B) ICO maximum amount allocated from initial supply--- 2,500,000{see
ICO}. The initial price is 128 EFT == 1 METIS.
</br>C) Any person may tweet #EFT-ICO on twitter to contribute to the
Burning of up to 1,000,000 tokens.{see burn phase 1 for details}
</br>D) After one month from the publishing of the contract, the ICO will
end
</br>E) Any portion of 2,500,000 million tokens left unsold will be
burned.
</br>F) Half of the funds received from the ICO will be used to create a
Liquidity Pool on Netswap, hard-coded in the contract. The Liquidity
Pool will begin with a 50% price increase 84 EFT == 1 METIS. This is to
encourage buying during the ICO period.
</br>G) A Sold-Ratio will be calculated and used to Burn the remaining
supply. {See Sold-Ratio}
</br>H) The second Burn Phase begins immediately and will last 4 months.
</br>I) Voting begins in which the community may vote on what hashtags
they want to promote.{See voting}
</br>J) The Burning of tokens will be based on the number of tweets of
the voted upon hashtag.{see Burn phase 2}
</br>K) After 4 months, the second Burn Phase will end
</br>L) The Third Burn Phase will begin and last 6 months. It will have
the same the structure as the Second Phase, but depending on how the
Second Phase proceeded, may have a different burn algorithm.
</br>M)Voting will be the same as the Second Phase
</br>N)Burning will be the same, barring a change to the algorithm.
</br>O)After 6 months, the Third Phase will end.
</br>P)Staking begins and will be permanent. {See staking}
</br>Q)These lines indicate that whatever tokens apportioned for the burn
phase that are not burned shall trickle down into staking, thus
increasing the pool of tokens that may be earned through staking.
