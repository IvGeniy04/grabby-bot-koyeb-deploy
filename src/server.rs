use actix_web::{get, App, HttpResponse, HttpServer, Responder};
use std::env;
use tracing::info;

#[get("/")]
async fn health_check() -> impl Responder {
    HttpResponse::Ok().body("I'm alive!")
}

pub async fn run_web_server() -> std::io::Result<()> {
    let port_str = env::var("PORT").unwrap_or_else(|_| "8080".to_string());
    let port = port_str.parse::<u16>().unwrap_or(8080);
    info!("Starting web server on port: {}", port);

    HttpServer::new(|| {
        App::new().service(health_check)
    })
    .bind(("0.0.0.0", port))?
    .run()
    .await
}
