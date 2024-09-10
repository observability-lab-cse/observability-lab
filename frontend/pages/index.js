import { useState, useEffect } from 'react';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faPaperPlane, faTrash, faPen } from '@fortawesome/free-solid-svg-icons'


function ChatInterface() {
  const [messages, setMessages] = useState([]);
  const [inputText, setInputText] = useState('');

  const sendMessage = () => {
    if (inputText.trim()) {
      setMessages([...messages, { sender: 'User', text: inputText }]);
      // Call AI API and append AI's response
      setMessages([...messages, { sender: 'User', text: inputText }, { sender: 'AI', text: 'AI response placeholder' }]);
      setInputText(''); // Clear the input field
    }
  };

  const handleKeyPress = (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      sendMessage();
    }
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', height: '100%' }}>
      {/* Chat history */}
      <div style={{ flex: 1, overflowY: 'auto', padding: '10px', border: '1px solid #ccc', marginBottom: '10px', overflowY: 'scroll', }}>
        {messages.map((message, index) => (
          <div key={index} style={{ marginBottom: '10px', textAlign: message.sender === 'AI' ? 'left' : 'right' }}>
            <strong>{message.sender}:</strong> {message.text}
          </div>
        ))}
      </div>

      {/* Input area */}
      <div style={{
        display: 'flex', alignItems: 'center', borderTop: '1px solid #ccc', padding: '10px'
      }}>
        < textarea
          style={{
            flex: 1,
            resize: 'none',
            padding: '10px',
            overflowY: 'scroll',
            height: '100px',
          }}
          rows={1}
          value={inputText}
          onChange={(e) => setInputText(e.target.value)}
          onKeyDown={handleKeyPress}
          placeholder="Type your message..."
        />
        <button onClick={sendMessage} style={{ marginLeft: '10px', padding: '10px 20px' }}>
          Send
          <FontAwesomeIcon icon={faPaperPlane} className="fa-fw" />
        </button>
      </div>
    </div >
  );
}

function DeviceManagement() {

  // State for storing the list of smart home devices
  const [devices, setDevices] = useState([]);
  // State for storing new device name and location
  const [newDeviceName, setNewDeviceName] = useState('');
  const [newDeviceLocation, setNewDeviceLocation] = useState('');

  useEffect(() => {
    // Fetch the data from the API endpoint
    // fetch('https://api.example.com/devices')
    //   .then(response => response.json())
    //   .then(data => setDevices(data))
    //   .catch(error => console.error(error));

    setDevices([{ name: "Device1", location: "Location1" },
    { name: "Device2", location: "Location2" },
    { name: "Device3", location: "Location3" }])
  }, []);

  // Handler for adding a new device
  const addDevice = (e) => {
    e.preventDefault();
    if (newDeviceName && newDeviceLocation) {
      setDevices([...devices, { name: newDeviceName, location: newDeviceLocation }]);
      setNewDeviceName('');  // Clear input fields
      setNewDeviceLocation('');
    }
  };

  // Handler for deleting a device
  const deleteDevice = (index) => {
    setDevices(devices.filter((_, i) => i !== index));
  };

  // Handler for editing a device (simplified)
  const editDevice = (index) => {
    const device = devices[index];
    const newName = prompt("Edit device name:", device.name);
    const newLocation = prompt("Edit device location:", device.location);
    if (newName && newLocation) {
      const updatedDevices = [...devices];
      updatedDevices[index] = { name: newName, location: newLocation };
      setDevices(updatedDevices);
    }
  };

  return (
    <>
      <div style={{ height: '60%', marginBottom: '20px', border: '1px solid #ccc', paddingTop: '30px'}}>
        <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
          {devices.map((device, index) => (
            <div
              key={index}
              style={{
                display: 'flex',
                alignItems: 'center',
                border: '1px solid #ccc',
                borderRadius: '5px',
                marginLeft: '30px',
                padding: '10px',
                width: '40vw',
                boxSizing: 'border-box',
                backgroundColor: '#f9f9f9',
              }}
            >
              {/* Device name and location */}
              <div>
                <strong>{device.name}</strong>
                <div style={{ fontSize: '0.9em', color: '#555', textIndent: '20px' }}>Location: {device.location}</div>
              </div>
              {/* Edit and Delete buttons */}
              <div style={{ display: 'flex', flexDirection: 'column', marginLeft: 'auto' }}>
                <button onClick={() => editDevice(index)} style={{ margin:'5px', padding: '5px' }}><FontAwesomeIcon icon={faPen} className="fa-fw" /></button>
                <button onClick={() => deleteDevice(index)} style={{ margin:'5px', padding: '5px' }}><FontAwesomeIcon icon={faTrash} className="fa-fw" /></button>
              </div>
            </div>
          ))}
        </div>
      </div>
      {/* Form to add a new device */}
      <div style={{ height: '30%', border: '1px solid #ccc', position: 'relative', padding: '20px' }}>
        <h3>Add New Device</h3>
        <form onSubmit={addDevice} style={{ display: 'flex', flexDirection: 'column', height: '90%' }}>
          <div style={{ marginBottom: '5px' }}>
            <label>
              Name:
              <input
                type="text"
                value={newDeviceName}
                onChange={(e) => setNewDeviceName(e.target.value)}
                style={{ display: 'block', width: '30%', padding: '5px' }}
              />
            </label>
          </div>
          <div style={{ marginBottom: '5px' }}>
            <label>
              Location:
              <input
                type="text"
                value={newDeviceLocation}
                onChange={(e) => setNewDeviceLocation(e.target.value)}
                style={{ display: 'block', width: '30%', padding: '5px' }}
              />
            </label>
          </div>
          <button type="submit" style={{ alignSelf: 'flex-end', padding: '10px 20px' }}>
            Add Device
          </button>
        </form>
      </div>

    </>
  );
}


export default function Home() {


  return (
    <div style={{ display: 'flex', height: '90vh' }}>
      {/* Left 2/3 of the screen */}
      <div style={{ width: '66%', padding: '20px', boxSizing: 'border-box' }}>
        <h2>Smart Home Devices</h2>
        <DeviceManagement />
      </div>

      {/* Right 1/3 of the screen */}
      <div style={{ width: '34%', padding: '20px', boxSizing: 'border-box', borderLeft: '1px solid #ccc' }}>
        <h2>AI Assistant</h2>
        <ChatInterface />
      </div>
    </div>
  );
}
