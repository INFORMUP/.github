#  Welcome to InformUp

# Introduction
The goal of InformUp is to dramatically increase the rate of local civic participation by giving residents the information they need to be informed and then the tools to easily take action on that information. This requires a significant investment in software based tools that not only simplify the collection of civic information and the generation of high quality reporting, but also in tools to distribute that reporting, and most importantly, provide engaging ways for residents to participate in their local government.
# Open Source at InformUp
Our goal is to create a welcoming community of volunteer software developers who can help to develop the tools that InformUp rely on to deliver on our core mission. While InformUp is the primary user of these tools, our aim is to guide their development but not to keep them proprietary. In the same way that no one should have to pay to have access to their elected officials, no advocacy organization, no news room, no motivated citizen should have to pay to use tools to help inform and organize their communities.
## **The need for Software engineering**
#### Managing
While there are off the shelf tools that can be used for part or some of our mission, those tools need to be deployed, managed, and often extended to suit the needs of inform up. 
>  For example, we use the Open Source Content Management System Ghost to host our website and news letter, we need to  customize the Themes to match the branding and layout of our content.
### Extending
Beyond the general management of existing products, we need to adapt and develop our own tools. Informup does not create traditional news articles, but an integrated news/survey product, which requires creative uses of Survey APIs.
### Creating
There are problems that have never been solved before (in code), that thanks to AI are now very possible. From automating the collection of meeting agendas, transcripts, and legislation to synthesize draft articles for human review, to generating meeting transcripts at scale, AI is  an incredibly powerful tool to help our reporters be better. 
## How Things are Organized
### Projects
Our engineering work is loosely organized into projects
#### The Website - Informup.org
- Hosting (Ghost CMS on AWS)
- Design (Theme development)
- Feature Enhancements
	- Social Share card for Survey responses
	- Support for multiple cities
	- Ability for people to specify their address/district

#### Survey Tools - Formbricks
- Hosting?
#### Reporter Dashboard
- Collection of Public Meeting content
- Generation of Draft Articles
- Aggregation of Survey results into presentable format
**Analog Meetings**
- Automated Emailing of Clerks/admin for agendas and legislation
- Meeting Recording Upload and transcription
#### Experiments
- Transcription and summarization of public comment
- Tools for local governments to easily digitize their workflows
### How to get involved
