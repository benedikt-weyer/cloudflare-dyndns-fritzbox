{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    python310
    openssl
  ];

  shellHook = ''
    echo "Python 3.10 development environment"
    echo "Python version: $(python --version)"
    echo ""
    
    # Create virtual environment if it doesn't exist
    if [ ! -d ".venv" ]; then
      echo "Creating virtual environment in .venv..."
      python -m venv .venv
    fi
    
    # Activate virtual environment
    echo "Activating virtual environment..."
    source .venv/bin/activate
    
    # Install/update project dependencies
    echo "Installing project dependencies..."
    pip install -e .
    
    echo ""
    echo "Virtual environment activated and dependencies installed!"
    echo "To run the application:"
    echo "  python src/main.py"
  '';
} 