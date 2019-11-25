# History

Code versioning is explained in the [Trade Control node core](https://github.com/tradecontrol/tc-nodecore/blob/master/readme.md#versioning) repository and something of its history in [Coding Practice](https://github.com/tradecontrol/tc-nodecore/blob/master/docs/tc_coding_practice.md). The scripts can be opened from the VS project or directly in SMS. Although meaningless, you could get to the open source release by installing the first [creation script](../src/scripts/v1/Create_Schema_1.01.sql) in 2008, then applying each upgrade script in version sequence and the conversion scripts between 2 and 3. 

> **Note**
> 
> The referenced companies are legal entities that operate as commercial vehicles for my self-employment. Trade Control Ltd is the current incarnation.

## sharpNode

The [sharpNode](../src/scripts/sharpNode/sharp_node_2002_03.sql) from 2002 was the product of a project that I began in the mid-nineties, and was owned by Seesharp Ltd. It is a schema design that is founded on the same principles as Trade Control, except implemented with an uncompromising purity. As such, the schema model is highly recursive, and would be difficult to implement in live environments without a great deal of interface over-coding. Unlike Trade Control, it also supports manufacturing production, but the cash control dimensions were externally expressed in a VBA xls project called The Cash which has been lost. Trade Control is a simplified version of the sharpNode combined with a more sophisticated implementation of The Cash.

During the eighties and nineties, the manufacturing industry in England was still well established and buoyant enough for contract systems programming services to be in high demand. The MRP/ERP systems at that time were complex and expensive, and I had spent much of my working days customising them since leaving Uni in the eighties. During the mid-nineties, with the new desktop development environments evolving, I saw an opening for a cutdown MRP system for SME's that I could code myself, supported by my contract work. This would put me on the playing field so I could try out the ideas I was rapidly developing, many of which have been expressed in the [TC papers](tc_papers.md). 

There were then two schema designs associated with my quixotic quest: a conventional MRP control system that was ceaselessly modified in accordance with the whims of customer demand; and the gestating sharpNode, waiting for its opportunity to be born. The former was a Trojan Horse that I only cared about insofar as it put me on the playing field. My intention in 2002 was to install the MRP system in a supply chain, work with the players to find a practical implementation of the sharpNode, then link the nodes together using Biz Server. Today you would use blockchain technology, but the fundamental idea is the same.

Ultimately, however, for commercial reasons, the task proved too difficult to achieve. Seesharp was dissolved soon after the IPO of the Trojan Horse had fled. My quest was not so quixotic after all though: that horse did eventually canter out onto the field of play after an epic, award winning re-write; but alas the horse was empty! On the positive, because I was company owner and author, the IPO of the sharpNode passed to me, giving legal entitlement to release the schema design into the public domain.

There is no documentation, so it is a puzzle. By way of a clue, the schema design applies the [name-spacing](tc_functions.md#namespaces) described in Functions, only to to all the structures and processes of the business entity. That is why every subject and object is linked to **dbo.tbComponent**, including transformations and spatial/temporal mappings. 

### Installation

From Sql Management Studio, you can either run the [creation script](../src/scripts/sharpNode/sharp_node_2002_03.sql) on a blank database; or restore the original database from the [sharpNode.bak](../src/scripts/sharpNode/sharpNode.bak) file. The latter contains several schema diagrams which are informative. To gain access to these, open Properties/Files and take ownership of the database .

## Version 1

In 2007 I learnt of a start-up that required an MIS to help them get going. The available accounting software could not model their work processes and provide on-going job profitability reporting. I said: "I've got just the thing for you". Upon presenting them with the sharpNode they said, "This is mind-blowing!" and stated that they did not want to take a degree just to raise an order. I agreed and set about re-designing the architecture, resulting in the first release of Trade Control in March 2008. 

I formally separated out what I call the [_jacare_](tc_functions.md#organizations) (object, subject and project) and gave them friendly names (activities, organizations and tasks). The unfamiliar name-spacing function was completely removed from the schema. Instead component structure was modelled by a more traditional workflow design. Once references to manufacturing production had been expunged, I added the financial dimension using the [cash polarity principle](tc_functions.md#cash-polarity) I had implemented in The Cash 2002.

The product name of Version 1 was Trade Control, but the copyright was owned by a company called Tru-Man Industries Ltd. Tru-Man stood for True Manufacturing, and I incorporated the company in 2006 to market a new manufacturing system I was working on. In 2005 I saw an opportunity to have another go at getting on the playing field. The BOM in most production environments is a tree structure (where child nodes have only one parent) but there are a few industries where this does not apply. In some engineering processes the structure is a graph (where child nodes have more than one parent) and one of these is Injection Moulding (input -> plastic + master batch; output -> multiple components). Modelling injection moulding production in conventional systems is difficult because they begin with a tree structure and bolt on graph support in the form of disassembly operations. I reasoned that it was a practical project to provide the industry with a system written specifically for them, but with a generic sub-system that could be materialised when things got going. The supply chains were not too deep, but the competition was less, and it was the best possibility I had at the time.

I split the project into two halves: production processing and automation. The first involved modelling assemblages of moulded components and processing their serialised production from enquiry to weigh-counting and shipment. The second, attaching internet enabled PLCs to the moulding machines and monitoring production against a finite schedule, emitting alarms and notifications in real-time. The first half was complete by 2008, so I packaged it up and marketed the app with a colleague who had over 40 years’ experience in the industry. By early 2000, the mould tooling industry had been largely destroyed by sub-contraction to China, but we found that a similar fate had now befallen the factories that used those tools. The ones that remained had their own IPO and costly IT systems, or they were de-skilled and run by amateurs. Not only had the jolly bankers decimated my industry in their unbridled appetite for profit, in 2008 they successfully sucked the global economy down a black hole of debt from which it is yet to recover. No-one was buying!

We abandoned our attempt to introduce the app into the industry. Trade Control was put on ice, except I continued to support it. This is reflected in the fact that scripts post version 1.06 make exclusive use of the ```ALTER``` command, but not one ```CREATE```.

## Version 2

Although I realised the ship had sailed, after 2008 I continued to work on the automation system until I completed it in 2011. It was a personal achievement that only I appreciated! Because the Tru-Man project no longer interested me commercially, I thought to isolate its IPO by extracting the Trade Control app into a new company and try to sell that instead. That is why Trade Control Ltd, incorporated in the same year, is eponymous and version 2 is basically a re-branding exercise.

Not wishing to market the app myself, I wrote some literature, an NDA and approached various distributors. Either they wanted to own 100% of the IPO or they refused to sign the NDA. For one reason or another, not one got to see the app in action. 

So, I maintained the Tru-Man production system and the factory's IT infrastructure. I wrote reports, which today they call Business Intelligence. I attached speed controllers to the cooling towers and turned them with a PLC in a PID loop, internet enabled so the temperature of the machine coolant could be set from the other side of the world. In short, I waited for the inevitable. The alarms I had installed on the machines began to flare up like Christmas lights and were ignored. The siren on the sabotaged cooling towers gagged with an old rag. In 2014 the factory, trading since 1946, went bust.

## Version 3

Having been self-employed for over 25 years, my CV is somewhat self-referential. Without employment contracts, your commercial life can be difficult to explain. On a pragmatic level, the Version 3 open source release of Trade Control is both my alternative to an employee's CV and this, an attempt to stimulate some interest in the app. But, of course, it is more than that.

When the injection moulding factory closed, I stuck around to provide the receivers with information and help with the clean-up operation. Trucks from across the European continent hauled up to take away the auctioned off moulding machines, cranes, mould tools, lathes and so forth. The pile in the middle of the shop floor gradually evaporated until it opened out like the empty belly of a beached whale. 

The factory is a zone of confluence for many different forces. There is the objective reality of applied science and engineering; and the subjective world of its customers, suppliers, workers and the markets that serve them. For almost three decades I had stared into the gap that lay between them with unending fascination. The vortexes of production are exhilarating, but they can also be a harsh and unforgiving place. Yet in my own way, despite being thwarted perpetually in my quest, I had obtained mastery over them. My last contribution to the British Manufacturing Industry was to clean out the loos. Tru-Man curled up in the corner of the shop floor and expired. I cycled round the empty factory, pulled a few wheelies and was gone.

The dissolution of the company in 2019 was a formality I had put off for too long. The IPO of the Tru-Man manufacturing system transferred to Trade Control.

