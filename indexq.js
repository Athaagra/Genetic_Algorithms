const request = require("request-promise");
const regularRequest = require("request");
const fs = require("fs");
const axios = require('axios');
const cheerio = require("cheerio"); 
const Nightmare = require("nightmare");
const nightmare = Nightmare({show:false});
const os =require("os");
const http = require("http");
const https = require("https");
const download = require('image-downloader');
const createStreamableFile = require('node-streamable-file');
const open = require('node:fs/promises');
const basename = require('node:path');
const cron = require("node-cron");
const FileDownload = require("crawlee");
const saveAs = require("file-saver");
var LocalStorage = require('node-localstorage').LocalStorage,
localStorage = new LocalStorage('./scratch');

//var task = cron.schedule('* */5 * * * *', () => {
//console.log('Cron job started at', new Date());
//try {

async function scrapeTitlesRanksAndRatings() {
	const result = await request.get("https://www.eporner.com/");
	const $ = await cheerio.load(result);
	const movies = $("div.mb").map((i, element) => {
		const title = $(element).find("div.mbunder > p.mbtit > a").text();
		const user_id =1;
		const url ="https://www.eporner.com"+$(element).find("div.mbimg > div.mbcontent > a").attr('href');
		const body =$(element).find("div.mbimg > div.mbcontent > a").attr('href');
		//const url_video="https://www.eporner.com/embed/"+embt[0];
		return {user_id,title,url,body};
	}).get();
	//console.log(movies);
	return movies;
}

async function scrapePosterUrl(movies){
	const moviesWithPosterUrls = await Promise.all(
	movies.map(async movie => {
	try {
		const html = await request.get(movie.url);
		const $ = await cheerio.load(html);
		const categorics = $("#video-info-tags").text();
		const concategories = categorics.replace(/\s+/g, "");//''.concat(categorics);
		//console.log('Those are splittedCategories',categorics);
		movie.category_id = concategories.toUpperCase(); 
		movie.imgUrl = '';
		//var movietitle = movie.title;
		movie.imgName = categorics.match(/[A-Z]/g).join(''); 
		movie.posterUrl = $("#EPvideo").attr('poster');
		movie.pornstar=$(".vit-pornstar > a:nth-child(1)").text();
		movie.industry = $("#cppbar > div:nth-child(2) > h2:nth-child(1) > a:nth-child(1)").text()
		//movie.video_url ="https://www.eporner.com/embed/" + emb;
		return movie;
		//}
	} catch (err) {
		console.log(err);
	}
	}));
	return moviesWithPosterUrls;
}


async function scrapePosterImageUrl(movies){
	for (var i=0; i<movies.length; i++){
	 try {
	   if (typeof movies[i].imgName !== 'undefined'){
		movies[i].imgGifs = await i+movies[i].imgName+'.webm';
		movies[i].imgName = await i+movies[i].imgName+'.png';
		movies[i].imgUrl=await __dirname+'/posters/'+movies[i].imgName;
		movies[i].gifUrl=await __dirname+'/gifs/'+movies[i].imgGifs;
		console.log('This is the posterUrl',movies[i].posterUrl);
		const posteru=movies[i].posterUrl.split("/");
		console.log('This is the poster image',posteru[posteru.length-2]);
		posteru[posteru.length-1]=posteru[posteru.length-2]+'-preview.webm';
		movies[i].posteras=await posteru.join('/');
		console.log(movies[i].posteras);
		await savePosterImageToDisk(movies[i],i);
		await savePosterasImageToDisk(movies[i],i);
		//console.log('this is b and i',b,i);
		//movies[b]=undefined;
		const imgUrla = await nightmare
			.goto(movies[i].posterUrl)
			.evaluate(() => 
			$(
			"body > img:nth-child(1)").attr("src")
			);
		//movies[i].imgUrla = imgUrla;
	   }
	 } catch (err){
		 console.log(err);
	 }
	}
	return movies;
}


function embedVideo(movies){
	for (var i=0; i<movies.length; i++){
	try{
		const code = movies[i].body;
		if (typeof code !== 'undefined'){
			var coded = code.slice(7,19);
			var embV= "https://www.eporner.com/embed/" + coded;
			movies[i].body=embV;
			const pornstar= movies[i].pornstar;
			if (pornstar !== ""){
				const pornas = pornstar.split(/(?=[A-Z])/);
				movies[i].pornstar= pornas[0]+""+pornas[1];
			} else {
				movies[i].pornstar="";
			}
			const industry= movies[i].industry;
			if (industry !== ""){
				if (industry==="Brazzers Videos" || industry==="Brazzers Network"){
					movies[i].industry="Brazzers";
				}
				else if (industry==="Reality Kings Videos" || industry==="Reality Kings Clips"){
					movies[i].industry="Reality Kings";
				}
				else if (industry==="Mofos Network" || industry==="Mofos Videos"){
					movies[i].industry="MOFOS";
				}
				else if (industry==="Naughty Bookworms" || industry==="Naughty Office" || industry==="Naughty Athletics" || industry==="Naughty Mag"){
					movies[i].industry="Naughty America";
				}
				else if (industry==="Taboo Heat"){
					movies[i].industry="TABOOHEAT";
				}
				else if (industry==="Vixenplus"){
					movies[i].industry="VIXEN";
				}
				else if (industry==="MOMMY'S GIRL OFFICIAL"){
					movies[i].industry="Mommys Girl";
				}
				else if (industry==="MOMMY'S BOY"){
					movies[i].industry="Mommys boy";
				}
				else if (industry==="Bangbros Videos" || industry==="Bangbros Network"){
					movies[i].industry="BANGBROS";
				}
				else if (industry==="Glory Hole Secrets" || industry==="Glory Hole TOP Secrets"){
					movies[i].industry="GloryHoleSecrets";
				}
				else if (industry==="The One Gloryhole"){
					movies[i].industry="TheOneGloryHole";
				}
				else if (industry==="Blacked RAW"){
					movies[i].industry="BLACKEDRAW";
				}
				else if (industry==="Evil Erotic Official"){
					movies[i].industry="Evil Erotic";
				}
				else if (industry==="GIRLSWAY OFFICIAL"||industry==="Girlsway Network"){
					movies[i].industry="Girlsway";
				}
				else if (industry==="Girlfriends Films Videos" || industry==="GirlfriendsFilms Videos"){
					movies[i].industry="Girlfriends Films";
				}
				else if (industry==="Evil Angel Network" || industry==="Evil Angel"){
					movies[i].industry="EvilAngel";
				}
				else if (industry==="Jasmine Black Videos"){
					movies[i].industry="Jasmine Black";
				}
				else if (industry==="Milfed Videos"){
					movies[i].industry="Milfed";
				}
				else if (industry==="Family Sinners Videos"){
					movies[i].industry="Family Sinners";
				}
				else if (industry==="Filthy Kings"){
					movies[i].industry="FILTHYKINGS";
				}
				else if (industry==="Loank"){
					movies[i].industry="Loan4k";
				}
				else if (industry==="Breed me"){
					movies[i].industry="BreedMe";
				}
				else if (industry==="Property Sex Videos"){
					movies[i].industry="Property Sex";
				}
				else if (industry==="Sweet Sinners Videos"){
					movies[i].industry="Sweet Sinners";
				}
				else if (industry==="Twistys Videos"){
					movies[i].industry="Twistys";
				}
				else if (industry==="Porn Land Videos"){
					movies[i].industry="Porn Land";
				}
				else if (industry==="K Porn"){
					movies[i].industry="5Kporn";
				}
				else if (industry==="MetroHD Videos"){
					movies[i].industry="MetroHD";
				}
				else if (industry==="Sweet Heart Videos"){
					movies[i].industry="Sweet Heart";
				}
				else if (industry==="My Pervy family"){
					movies[i].industry="MyPervy family";
				}
				else if (industry==="Perv Mom"){
					movies[i].industry="PERVMOM";
				}
				else if (industry==="Digital Playground Videos"){
					movies[i].industry="Digital Playground";
				}
				else if (industry==="Fake Hub Videos"){
					movies[i].industry="Fake Hub";
				}
				else if (industry==="Touch My Wife"){
					movies[i].industry="touchMywife";
				}
				else if (industry==="Hentai Pros Videos"){
					movies[i].industry="Hentai Pros";
				}
				else if (industry==="Transsensual Videos"){
					movies[i].industry="Transsensual";
				}
				else if (industry==="TransAngels Videos"){
					movies[i].industry="TransAngels";
				}
				else if (industry==="Mature NL Videos"){
					movies[i].industry="Mature.nl";
				}
				else if (industry==="Fake Taxi Videos"){
					movies[i].industry="Fake Taxi";
				}
				else if (industry==="Men Videos"){
					movies[i].industry="Men";
				}
				else {
					movies[i].industry=industry;
				}
			} else {
				movies[i].industry="";
			}
			const titlem = movies[i].title.toUpperCase();
			const category = movies[i].category_id.toUpperCase();
			if (typeof titlem !== 'undefined'){
					if (titlem.indexOf("AMATEUR") !==-1){
						movies[i].category_id = 1;
					}
					else if (titlem.indexOf("LESBIAN") !==-1){
						movies[i].category_id = 2;
					}
					else if (titlem.indexOf("BLOWJOB") !==-1){
						movies[i].category_id = 3;
					}
					else if (titlem.indexOf("MILF") !==-1){
						movies[i].category_id = 4;
					}
					else if (titlem.indexOf("BDSM") !==-1){
						movies[i].category_id = 5;
					}
					else if (titlem.indexOf("GAY") !==-1){
						movies[i].category_id = 6;
					}
					else if (titlem.indexOf("CUCKOLD") !==-1){
						movies[i].category_id = 7;
					}
					else if (titlem.indexOf("FACIAL") !==-1){
						movies[i].category_id = 8;
					}
					else if (titlem.indexOf("BISSEXUAL") !==-1){
						movies[i].category_id = 9;
					}
					else if (titlem.indexOf("ANIME") !==-1){
						movies[i].category_id = 10;
					}
					else if (titlem.indexOf("GLORYHOLE") !==-1){
						movies[i].category_id = 11;
					}
					else if (titlem.indexOf("LINGERIE") !==-1){
						movies[i].category_id = 12;
					}
					else if (titlem.indexOf("ANAL") !==-1){
						movies[i].category_id = 13;
					}
					else if (titlem.indexOf("MASSAGE") !==-1){
						movies[i].category_id = 14;
					}
					else if (titlem.indexOf("ORGY") !==-1){
						movies[i].category_id = 15;
					}
					else if (titlem.indexOf("BIGTITS") !==-1){
						movies[i].category_id = 16;
					}
					else if (titlem.indexOf("CELEBRITIES") !==-1){
						movies[i].category_id = 17;
					}
					else if (titlem.indexOf("EBONY") !==-1){
						movies[i].category_id = 18;
					}
					else if (titlem.indexOf("CREAMPIE") !==-1){
						movies[i].category_id = 19;
					}
					else if (titlem.indexOf("INTERRACIAL") !==-1){
						movies[i].category_id = 20;
					}
					else if (titlem.indexOf("POV") !==-1){
						movies[i].category_id = 21;
					}
					else if (titlem.indexOf("BIGDICK") !==-1){
						movies[i].category_id = 22;
					}
					else if (titlem.indexOf("PERFECTBODY") !==-1){
						movies[i].category_id = 23;
					}
					else if (titlem.indexOf("BBC") !==-1){
						movies[i].category_id = 24;
					}
					else if (titlem.indexOf("MASTURBATE") !==-1){
						movies[i].category_id = 25;
					}
					else if (titlem.indexOf("THREESOME") !==-1){
						movies[i].category_id = 26;
					}
					else if (titlem.indexOf("BUKKAKE") !==-1){
						movies[i].category_id = 27;
					}
					else{
						const titlema=3;
					}	
			}
			if (typeof category !== 'undefined' && movies[i].category_id.length > 3){
					if (category.indexOf("AMATEUR") !==-1){
						movies[i].category_id = 1;
					}
					else if (category.indexOf("LESBIAN") !==-1){
						movies[i].category_id = 2;
					}
					else if (category.indexOf("BLOWJOB") !==-1){
						movies[i].category_id = 3;
					}
					else if (category.indexOf("MILF") !==-1){
						movies[i].category_id = 4;
					}
					else if (category.indexOf("BDSM") !==-1){
						movies[i].category_id = 5;
					}
					else if (category.indexOf("GAY") !==-1){
						movies[i].category_id = 6;
					}
					else if (category.indexOf("CUCKOLD") !==-1){
						movies[i].category_id = 7;
					}
					else if (category.indexOf("FACIAL") !==-1){
						movies[i].category_id = 8;
					}
					else if (category.indexOf("BISSEXUAL") !==-1){
						movies[i].category_id = 9;
					}
					else if (category.indexOf("ANIME") !==-1){
						movies[i].category_id = 10;
					}
					else if (category.indexOf("GLORYHOLE") !==-1){
						movies[i].category_id = 11;
					}
					else if (category.indexOf("LINGERIE") !==-1){
						movies[i].category_id = 12;
					}
					else if (category.indexOf("ANAL") !==-1){
						movies[i].category_id = 13;
					}
					else if (category.indexOf("MASSAGE") !==-1){
						movies[i].category_id = 14;
					}
					else if (category.indexOf("ORGY") !==-1){
						movies[i].category_id = 15;
					}
					else if (category.indexOf("BIGTITS") !==-1){
						movies[i].category_id = 16;
					}
					else if (category.indexOf("CELEBRITIES") !==-1){
						movies[i].category_id = 17;
					}
					else if (category.indexOf("EBONY") !==-1){
						movies[i].category_id = 18;
					}
					else if (category.indexOf("CREAMPIE") !==-1){
						movies[i].category_id = 19;
					}
					else if (category.indexOf("INTERRACIAL") !==-1){
						movies[i].category_id = 20;
					}
					else if (category.indexOf("POV") !==-1){
						movies[i].category_id = 21;
					}
					else if (category.indexOf("BIGDICK") !==-1){
						movies[i].category_id = 22;
					}
					else if (category.indexOf("PERFECTBODY") !==-1){
						movies[i].category_id = 23;
					}
					else if (category.indexOf("BBC") !==-1){
						movies[i].category_id = 24;
					}
					else if (category.indexOf("MASTURBATE") !==-1){
						movies[i].category_id = 25;
					}
					else if (category.indexOf("THREESOME") !==-1){
						movies[i].category_id = 26;
					}
					else if (category.indexOf("BUKKAKE") !==-1){
						movies[i].category_id = 27;
					}
					else{
						movies[i].category_id = 3;
						
					}
					
				}
		}
	} catch (err){
		console.log(err);
	}
	}
	return movies;
}



async function savePosterImageToDisk(movie,i){
	await regularRequest
		.get(movie.posterUrl)
		.pipe(fs.createWriteStream(`posters/${movie.imgName}`));
}

async function savePosterasImageToDisk(movie,i){
	console.log('This the gifs',i);
	try {
		const videoUrl = movie.posteras; // The video URL passed as a query parameter
		const response = await axios({
			url: videoUrl,
			method: 'GET',
			responseType: 'stream',
		});
		await response.data.pipe(fs.createWriteStream(__dirname+'/gifs/'+movie.imgGifs,{flags: 'w', encoding: 'utf-8',mode: 0666}));
  } catch (error) {
    //console.error('Error downloading the video:', error);
	//movies[i] = undefined;
	//return i;
    //res.status(500).json({ success: false, error: 'Failed to download the video.' });
  }
 
}

async function fileToBlob(filePath) {
    //try {
		const buffer = await fs.openAsBlob(filePath);
		const mimeType = filePath.endsWith('.png') ? 'image/png' : 'image/jpeg';
    //} catch (error) {
	//		console.log(error);
	//}
	return new Blob([buffer], { type: mimeType });
}
async function fileToBloben(filePath) {
	//try {
		const buffer = await fs.openAsBlob(filePath);
		const mimeType = filePath.endsWith('.webm') ? 'video/webm' : 'video/mp4';
	//} catch (error) {
	//		console.log(error);
	//}
    return new Blob([buffer], { type: mimeType });
}
async function main() {
	 try {
		let movies = await scrapeTitlesRanksAndRatings();
		movies = await scrapePosterUrl(movies);
		movies = await scrapePosterImageUrl(movies);
		movies = await embedVideo(movies);
		//console.log('This is the movies length',movies.length);
		//console.log(movies);
		for (var i=0; i<movies.length; i++){
		   if (typeof movies[i] !== 'undefined'){ 
		     if (fs.existsSync(movies[i].imgUrl) && fs.existsSync(movies[i].gifUrl)){ 
			console.log('This is the img Url',movies[i].imgUrl);
			movies[i].gifUrl= await movies[i].gifUrl;
			console.log('Those are filepaths',movies[i].gifUrl,i);
			const blob = await fileToBlob(movies[i].imgUrl);
			const bloben = await fileToBloben(movies[i].gifUrl);
			const filename = await movies[i].imgName;
			const gifname = await movies[i].imgGifs;
			console.log('This is the category',movies[i].category_id);
			const formData = new FormData();
			const formVideo = new FormData();
			let user ={
				"user_id":movies[i].user_id,
				"category_id":movies[i].category_id,
				"title":movies[i].title.toString().trim(),
				"body":movies[i].body.toString().trim(),
				"cover":filename,
				"gifname":gifname,
				"pornstar":movies[i].pornstar.toString().trim(),
				"industry":movies[i].industry.toString().trim()
				}
			formData.set('file',blob,filename);//,cover,name);
			formVideo.set('gif',bloben,gifname);//,cover,name);
			let usera=JSON.stringify(user);
			localStorage.setItem("form", usera);
			let useraa = localStorage.getItem("form");
			if (typeof useraa!== 'undefined'){
			//console.log('This is data',usera);
			await fetch("https://www.xvybez.com/newfile.php",{
				"method":"POST",
				"headers":{
					'Accept': 'application/json, application/xml, text/plain, text/html, *.*',
                    'Content-Type': 'multipart/form-data'
				},
				"body" :useraa
			}).then(function(response){ 
				//return response.json();
			}).then(function(data){ 
				//console.log(data);
			})
			await fetch("https://www.xvybez.com/newfile.php", {
				method: 'POST',
				body: formData
			}).then(function(res){ 
				//return response.json();
			}).then(function(data){ 
				//console.log(data);
			})
			await fetch("https://www.xvybez.com/newfile.php", {
				method: 'POST',
				body: formVideo
			}).then(function(res){ 
				//return response.json();
			}).then(function(data){ 
				//console.log(data);
			})
			//.then(res => console.log(res))
			//.then(data => console.log(data))
			//.catch(err => console.log(err));
			}
		}
		}
		if (i===movies.length-1){
				//console.log('This');
				process.exit(1);
				return 0;
				//break;
			}
		}
	}
  catch (error) {
    console.error(error);
  }
}
//cron.schedule('* */5 * * * *', () => {
main();
//main();
//cron.schedule('* */5 * * * *',());
//	} catch (err) {
//      console.error('Cron job failed:', err);
//    }
//});
//task.start();