fn main() {
    let version = std::env::var("TOKEN").unwrap_or_default();
    let service_name =
        std::env::var("SERVICE_NAME").unwrap_or_else(|_| "v2boxHelperService".to_string());
    println!("cargo:rustc-env=TOKEN={}", version);
    println!("cargo:rustc-env=SERVICE_NAME={}", service_name);
    println!("cargo:rerun-if-env-changed=TOKEN");
    println!("cargo:rerun-if-env-changed=SERVICE_NAME");
}
